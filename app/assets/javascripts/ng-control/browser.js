(function() {
  let w = angular.module("aquarium");

  w.config([
    "$locationProvider",
    function($locationProvider) {
      $locationProvider.html5Mode({
        enabled: true,
        requireBase: false,
        rewriteLinks: false
      });
    }
  ]);

  w.controller("browserCtrl", [
    "$scope",
    "$http",
    "$attrs",
    "aqCookieManager",
    "$sce",
    "$window",
    "$mdDialog",
    function($scope, $http, $attrs, aqCookieManager, $sce, $window, $mdDialog) {
      AQ.init($http);
      AQ.update = () => {
        $scope.$apply();
      };
      AQ.confirm = msg => {
        return confirm(msg);
      };
      AQ.sce = $sce;

      function cookie() {
        var data = {
          version: $scope.views.version,
          project: {
            loaded: false,
            selected: $scope.views.project.selected,
            selection: $scope.views.project.selection,
            samples: []
          },
          recent: {
            selected: $scope.views.recent.selected
          },
          create: {
            selected: $scope.views.create.selected,
            samples: []
          },
          search: {
            selected: $scope.views.search.selected,
            query: $scope.views.search.query,
            sample_type: $scope.views.search.sample_type,
            project: $scope.views.search.project,
            project_filter: $scope.views.search.project_filter,
            user: $scope.views.search.user,
            user_filter: $scope.views.search.user_filter,
            item_id: $scope.views.search.item_id
          },
          sample_type: {
            selected: $scope.views.sample_type.selected,
            selection: {
              name: $scope.views.sample_type.selection.name,
              id: $scope.views.sample_type.selection.id,
              offset: $scope.views.sample_type.selection.offset,
              samples: []
            }
          },
          user: $scope.views.user
        };

        aqCookieManager.put_object("browserViews", data);
      }

      $scope.views = aqCookieManager.get_object("browserViews");

      if (!$scope.views || $scope.views.version !== 2) {
        $scope.views = {
          version: 2,
          project: {
            loaded: false,
            selection: {}
          },
          recent: {
            selected: false
          },
          create: {
            selected: false,
            samples: []
          },
          search: {
            selected: true,
            user: -1,
            user_filter: true
          },
          sample_type: {
            selected: false,
            selection: {}
          },
          user: { current: { login: "All", id: 0 } }
        };

        cookie();

        $scope.messages = [];
      } else {
        if (!$scope.views.sample_type) {
          $scope.views.sample_type = { selected: false };
        }
      }

      $scope.everyone = { login: "everyone", id: 0, name: "All Projects" };

      function init() {
        $scope.helper = new SampleHelper($http);

        $scope.user = new User($http, function(user_info) {
          if ($scope.views.search.user == -1) {
            $scope.views.search.user = user_info.current.login;
            $scope.search(0);
          }
          if (!$scope.views.user.initialized) {
            $scope.views.user.initialized = true;
            $scope.choose_user(user_info.current);
          } else {
            $scope.get_projects(function() {
              $scope.$apply();
            });
          }
        });

        $http
          .get("/sample_types.json")
          .then(function(response) {
            $scope.sample_types = response.data;
            $scope.sample_type_names = aq.collect(response.data, function(st) {
              return st.name;
            });
            if (
              $scope.views.sample_type.selected &&
              $scope.views.sample_type.selection
            ) {
              get_samples($scope.views.sample_type.selection);
            }
          })
          .then(() => {
            AQ.ObjectType.where({ handler: "collection" }).then(ots => {
              $scope.collection_types = ots;
            });
          });

        load_sample_names();

        if ($scope.views.search.user != -1) {
          $scope.search(0);
        }
      }

      $scope.openCollectionMenu = function($mdMenu, ev) {
        originatorEv = ev;
        $mdMenu.open(ev);
      };

      $scope.new_collection = function(collection_type) {
        AQ.Collection.new_collection(collection_type).then(collection => {
          window.location = `/items/${collection.id}`;
        });
      };

      $scope.get_projects = function(promise) {
        $scope.views.project.loaded = false;
        $.ajax({
          url: "/browser/projects?uid=" + $scope.views.user.current.id
        }).done(function(response) {
          $scope.views.project.projects = response.projects;
          $scope.views.project.loaded = true;
          $scope.projects = response.projects;
          if ($scope.views.project.selection.sample_type) {
            $scope.select_st(
              { id: $scope.views.project.selection.sample_type },
              true
            );
          }
          if (promise) {
            promise(response.projects);
          }
        });
      };

      function load_sample_names() {
        $scope.helper.autocomplete(function(sample_names) {
          $scope.sample_names = sample_names;
        });
      }

      // View Selection

      $scope.browser_control_class = function(view) {
        var c = "browser-control";
        if ($scope.views[view].selected) {
          c += " browser-control-on";
        }
        return c;
      };

      $scope.select_view = function(view) {
        for (key in $scope.views) {
          $scope.views[key].selected = false;
        }

        $scope.views[view].selected = true;
        cookie();

        if (view == "recent") {
          $scope.fetch_recent();
        }

        if (view == "sample_type" && $scope.views.sample_type.selection) {
          $scope.select_sample_type($scope.views.sample_type.selection);
        }
      };

      $scope.choose_user = function(user) {
        $scope.views.user.current = user;
        cookie();

        $scope.views.recent.samples = [];
        if ($scope.views.recent.selected) {
          $scope.fetch_recent();
        }

        $scope.views.project.loaded = false;
        $scope.get_projects(function(plist) {
          $scope.$apply();
        });
      };

      // Sample Type Chooser

      function get_samples(st) {
        var user_str = "";
        if ($scope.views.user.filter) {
          user_str = "/" + $scope.views.user.current.id;
        }
        $http
          .get(
            "/browser/samples/" + st.id + "/" + st.offset + user_str + ".json"
          )
          .then(function(response) {
            st.samples = [];
            new Sample($http);
            aq.each(response.data, function(s) {
              st.samples.push(new Sample($http).from(s));
            });
          });
      }

      $scope.offset = function(sign) {
        $scope.views.sample_type.selection.offset += sign * 30;
        $scope.views.sample_type.selection.samples = [];
        get_samples($scope.views.sample_type.selection);
        cookie();
      };

      $scope.select_sample_type = function(st) {
        $scope.views.sample_type.selection = st;
        if (!st.offset) {
          st.offset = 0;
        }
        get_samples(st);
        cookie();
      };

      $scope.unselect_sample_type = function(st) {
        if ($scope.views.sample_type.selection == st) {
          $scope.views.sample_type.selection = null;
        }
        cookie();
      };

      $scope.sample_type_from_id = function(stid) {
        return aq.where($scope.sample_types, function(st) {
          return stid == st.id;
        })[0];
      };

      $scope.by_user = function(sample) {
        return (
          !$scope.views.user.filter ||
          sample.user_id == $scope.views.user.current.id
        );
      };

      // Sample creation

      $scope.new_sample = function(st) {
        $scope.views.create.samples.push(
          new Sample($http).new(st.id, function() {
            $scope.select_view("create");
          })
        );
      };

      $scope.remove_sample = function(sample) {
        var i = $scope.views.create.samples.indexOf(sample);
        $scope.views.create.samples.splice(i, 1);
      };

      $scope.sample_type_from_name = function(name) {
        return aq.where($scope.sample_types, function(st) {
          return name == st.name;
        })[0];
      };

      $scope.sample_type_from_id = function(id) {
        return aq.where($scope.sample_types, function(st) {
          return id == st.id;
        })[0];
      };

      $scope.save_new_samples = function() {
        $scope.errors = [];
        $scope.helper.create_samples($scope.views.create.samples, function(
          response
        ) {
          if (response.errors) {
            $scope.errors = response.errors;
          } else {
            $scope.views.create.samples = [];
            $scope.choose_user($scope.user.current);
            $scope.views.search.query = "";
            $scope.views.search.sample_type = "";
            $scope.views.search.user = $scope.user.current.login;
            $scope.select_view("search");
            $scope.search(0);
            $scope.messages = aq.collect(response.samples, function(s) {
              return "Created sample " + s.id + ": " + s.name;
            });
            load_sample_names();
          }
        });
      };

      $scope.copy = function(sample) {
        var ns = angular.copy(sample).wipe();
        $scope.views.create.samples.push(ns);
        $scope.select_view("create");
      };

      function sample_inventory(samples, set_sample_state) {
        return aq.collect(samples, function(s) {
          console.log("s:")
          console.log(s);
          var sample = new Sample($http).from(s);
          if (sample && s.id === sample.id) {
            set_sample_state(sample);
          }
          console.log("sample:")
          console.log(sample);
          return sample;
        });
      }

      // TODO: this is only called by search when there is one item to be shown
      function show_inventory_for(item_id) {
        return (sample) => {
          sample.open = true;
          sample.inventory = true;
          sample.loading_inventory = true;
          sample.get_inventory(function() {
            sample.loading_inventory = false;
            sample.inventory = true;
          });
        }
      }

      function show_description(sample) {
        sample.open = false;
        sample.inventory = false;
      }

      // Search function handles all of the cases that depend on the state of the input fields
      $scope.search = function(p) {
        $scope.views.search.samples = [];
        $scope.views.search.status = "searching";
        $scope.views.search.page = p;

        $http.post("/browser/search", $scope.views.search).then(
          response => {
            $scope.views.search.status = "preparing";
            if ($scope.views.search.item_id) {
              // TODO: this should only include the item searched for or the collection containing it
              console.log("item")
              console.log(response.data.samples)
              $scope.views.search.samples = sample_inventory(
                response.data.samples,
                // TODO: use a function that filters inventory by item or collection ID
                show_inventory_for($scope.views.search.item_id)
              );
            } else {
              console.log("not item")
              $scope.views.search.samples = sample_inventory(
                response.data.samples,
                show_description
              );
            }
            $scope.views.search.count = response.data.count;
            $scope.views.search.pages = aq.range(response.data.count / 30);
            $scope.views.search.status = "done";
          },
          error => {
            console.log(error);
          }
        );
      };

      // remove_duplicate function removes duplicates in the list
      function remove_duplicate(list, prop) {
        return list.filter((obj, pos, arr) => {
          return arr.map(mapObj => mapObj[prop]).indexOf(obj[prop]) === pos;
        });
      }

      // search_update() function updates searched samples, count, page, and status
      function search_update(sample) {
        $scope.views.search.samples = sample_inventory(sample);
        $scope.views.search.count = 1;
        $scope.views.search.pages = aq.range(1 / 30);
        $scope.views.search.status = "done";
      }

      function find_collection(item) {
        AQ.Collection.find_fast(item.id).then(
          collection => {
            var item_list = collection.part_matrix.reduce(function(a, b) {
              return a.concat(b);
            });
            var sample;
            var sample_list = [];
            for (let i = 0; i < item_list.length; i++) {
              sample = item_list[i].sample;
              if (sample) {
                sample_list.push(sample);
              }
            }

            search_update(remove_duplicate(sample_list, "id"));
          },
          error => {
            $scope.views.search.status = "done";
            console.log("Error: " + error["errors"]);
          }
        );
      }

      function find_sample_type(sample_type_id) {
        AQ.SampleType.find(sample_type_id).then(
          sample_type => {
            if ($scope.views.search.sample_type == sample_type.name) {
              search_update([sample]);
              cookie();
              AQ.update();
            } else {
              $scope.views.search.status = "done";
            }
          },
          error => {
            console.log("Error: " + error["errors"]);
            $scope.views.search.status = "done";
          }
        );
      }

      function find_item_sample(item) {
        AQ.Sample.find(item.sample_id).then(
          sample => {
            // Current search inputs: Sample Name or ID, Item ID
            if ($scope.views.search.query) {
              if ($scope.views.search.query.includes(sample.id)) {
                // Current search inputs: Sample Name or ID, Sample Type, Item ID
                if ($scope.views.search.sample_type) {
                  find_sample_type(sample.sample_type_id);
                }
                search_update([sample]);
                cookie();
                AQ.update();
              } else {
                $scope.views.search.status = "done";
              }
            }

            // Current search inputs: Sample Type, Item ID
            else if ($scope.views.search.sample_type) {
              find_sample_type(sample.sample_type_id);
            }

            // Current search input: Item ID (only)
            else {
              search_update([sample]);
              cookie();
              AQ.update();
            }
          },
          error => {
            console.log("Error: " + error["errors"]);
            $scope.views.search.status = "done";
          }
        );
      }

      // TODO: this is dead code 
      // item_search function allows users to search for sample by Item ID
      $scope.item_search = function() {
        AQ.Item.find($scope.views.search.item_id).then(
          item => {
            AQ.ObjectType.find(item.object_type_id).then(object_type => {
              $scope.views.search.status = "preparing";
              if (object_type.handler === "collection") {
                find_collection(item);
              } else {
                find_item_sample(item);
              }
            });
          },
          error => {
            $scope.views.search.status = "done";
            console.log("Error: " + error["errors"]);
          }
        );
      };

      $scope.page_class = function(page) {
        var c = "page";
        if (page == $scope.views.search.page) {
          c += " page-selected";
        }
        return c;
      };

      // Messages

      $scope.dismiss_errors = function() {
        $scope.errors = [];
      };

      $scope.dismiss_messages = function() {
        $scope.messages = [];
      };

      $scope.noteColor = function(note) {
        if (note) {
          return { background: "#" + string_to_color(note, 40) };
        } else {
          return {};
        }
      };

      $scope.noteBlur = function(sample) {
        var note;

        if (!sample.data.note || sample.data.note === "") {
          note = "_EMPTY_";
        } else {
          note = sample.data.note;
        }

        $http({
          url: "/browser/annotate/" + sample.id + "/" + note + ".json",
          method: "GET",
          responseType: "json"
        });
      };

      $scope.button_heading_class = function(sample) {
        if (sample.open) {
          return "button-heading-open";
        } else {
          return "button-heading-closed";
        }
      };

      // When users click on the "Upload Samples" button,
      // upload_dialog function shows up a confirm dialog which is used to give users a note about the file format before uploading.
      $scope.upload_dialog = function() {
        let dialog = $mdDialog
          .confirm()
          .clickOutsideToClose(true)
          .title("Upload Samples From Local Computer")
          .textContent(
            "Spreadsheets should be in .csv format. The first entry of the first row should specify the sample type name. Remaining entries in the first row should be names of fields, the word 'Project', or the word 'Description'. Fields that correspond to arrays may show up multiple times, and can be empty (in which case the entry is ignored). The remaining rows specify the samples. In the first column should be the name of the sample. All other columns correspond to their headings. Subsamples can be referred to by name or id. "
          )
          .ariaLabel("Upload Samples")
          .ok("Upload")
          .cancel("Cancel");

        $mdDialog
          .show(dialog)
          .then(() => $(".input_sample").click(), () => null);
      };

      $scope.upload_change = function(files) {
        $scope.spreadsheet_name = files[0].name;
        $scope.upload();
      };

      $scope.upload = function() {
        $scope.spreadsheet_name = undefined;

        var f = document.getElementById("spreadsheet").files[0];
        var r = new FileReader();

        r.onloadend = function(e) {
          try {
            data = $scope.helper.spreadsheet(
              $http,
              $scope.sample_types,
              $scope.sample_names,
              e.target.result
            );

            $scope.views.create.samples = data.samples;
            $scope.messages = data.warnings;
            $scope.messages.push(
              "Spreadsheet '" +
                f.name +
                "' processed. Review the new samples below and click 'Save' to save this data to Aquarium."
            );
            $scope.select_view("create");
          } catch (e) {
            $scope.messages = ["Error processing spreadsheet: " + e];
            $scope.$apply();
          }
        };

        r.readAsText(f);
      };

      $scope.openMenu = function($mdMenu, ev) {
        originatorEv = ev;
        $mdMenu.open(ev);
      };

      if (aq.url_params().sid) {
        AQ.Sample.find(parseInt(aq.url_params().sid))
          .then(sample => {
            $scope.views.search.query = sample.identifier;
            $scope.views.search.sample_type = "";
            $scope.views.search.user_filter = false;
            $scope.views.search.project = "";
            $scope.views.search.project_filter = false;
            $window.history.replaceState(null, document.title, "/browser");
            cookie();
            init();
          })
          .catch(result => init());
      } else if (aq.url_params().stid) {
        AQ.SampleType.find(parseInt(aq.url_params().stid))
          .then(st => {
            $scope.views.search.query = "";
            $scope.views.search.sample_type = st.name;
            $scope.views.search.user_filter = false;
            $scope.views.search.project = "";
            $scope.views.search.project_filter = false;
            $window.history.replaceState(null, document.title, "/browser");
            cookie();
            init();
          })
          .catch(result => init());
      } else {
        init();
      }
    }
  ]);
})();
