(function() {
  var w = angular.module("aquarium");

  w.directive('focusedWhen', function() {
    return {
      scope: {
        focusedWhen: '=',
      },
      link: function($scope, $element) {
        $scope.$watch('focusedWhen', function(shouldFocus) {
          if (shouldFocus) {
            $element[0].focus();
          }
        });
      }
    };
  });

  w.controller("technicianCtrl", [
    "$scope",
    "$http",
    "$attrs",
    "$cookies",
    "$sce",
    function($scope, $http, $attrs, $cookies, $sce) {
      AQ.init($http);
      AQ.update = () => {
        $scope.$apply();
      };
      AQ.confirm = msg => {
        return confirm(msg);
      };

      let job_id = parseInt(aq.url_path()[2]);

      $scope.job_id = job_id;
      $scope.uploads = {};
      $scope.selects = [];
      $scope.item = null;
      $scope.mode = "steps";

      $scope.upload_config = {
        associate_with_operations: false,
        associate_with_plans: true
      };

      AQ.Job.find(job_id)
        .then(job => {
          $scope.job = job;
          $scope.job.recompute_getter("uploads");

          AQ.Job.active_jobs().then(job_ids => {
            if (
              job_ids.indexOf($scope.job_id) == -1 &&
              !job.backtrace.complete
            ) {
              $scope.zombie = true;
            }
            if (
              job.backtrace.last &&
              job.backtrace.last.timer &&
              !job.backtrace.complete
            ) {
              show_timer(job.backtrace.last.timer);
            }
            $scope.$apply();
          });
        })
        .catch(job => {
          $scope.not_found = true;
          $scope.$apply();
        });

      function show_timer(timer_spec) {
        $scope.mode = "timer";
        set_timer(timer_spec);
      }

      $scope.timer_button_text = function() {
        if (timer_on() && $scope.mode != "timer") {
          return timer_string();
        } else {
          return "Timer";
        }
      };

      $scope.content_type = function(line) {
        var type = Object.keys(line)[0];
        return type;
      };

      $scope.table_input = function(cell, response) {
        let x = aq.where(
          response.inputs.table_inputs,
          input => input.opid == cell.operation_id && input.key == cell.key
        )[0];
        if (x) {
          return x.value;
        } else {
          return null;
        }
      };

      $scope.content_value = function(line) {
        var k = Object.keys(line)[0];
        if (typeof line[k] === "string") {
          if (!line.html) {
            line.html = $sce.trustAsHtml(line[k]); // avoid infinte digest loops by caching result in line
          }
          return line.html;
        } else {
          return line[k];
        }
      };

      $scope.sce = function(data) {
        if (typeof data == "string") {
          return $sce.trustAsHtml(data);
        } else {
          return $sce.trustAsHtml(JSON.stringify(data));
        }
      };

      $scope.check = function(cell) {
        if (cell.check) {
          cell.checked = !cell.checked;
        }
      };

      $scope.table_class = function(cell, step) {
        var c = "no-highlight";
        if (cell == null) {
          c += " td-null-cell";
        } else if (cell.class) {
          c += " " + cell.class;
        }
        if (
          cell &&
          cell.check &&
          (cell.checked || !step.response.in_progress)
        ) {
          c += " td-checked";
        }
        if (cell && cell.check && !cell.checked && step.response.in_progress) {
          c += " td-notchecked";
        }
        if (cell && cell.type) {
          c += " td-input";
        }
        return c;
      };

      $scope.keyDown = function(evt) {
        switch (evt.key) {
          case "PageUp":
            event.preventDefault();
            if ($scope.job.state.index > 0) {
              $scope.job.state.index--;
            }
            break;
          case "PageDown":
            event.preventDefault();
            if ($scope.job.state.index < $scope.job.backtrace.length - 1) {
              $scope.job.state.index++;
            } else {
              $scope.ok();
            }
            break;
          case "a":
            if (evt.ctrlKey) {
              event.preventDefault();
              $scope.job.backtrace.last.check_all();
            }
            break;
          case "End":
            event.preventDefault();
            document.getElementById('content-container').focus();
            if ($scope.job.state.index < $scope.job.backtrace.length - 1) {
              $scope.job.state.index++;
            } else if (!$scope.job.backtrace.last.check_next()) {
              $scope.ok();
            }
            break;
          case "Home":
            event.preventDefault();
            document.getElementById('content-container').focus();
            if(!$scope.job.backtrace.last.uncheck_prev() && $scope.job.state.index > 0) {
              $scope.job.state.index--;
            }

          default:
        }
      };

      $scope.start_upload = function(id) {
        $("#upload-" + id).click();
        console.log(id);
      };

      function send_file(varname, id, file) {
        var r = new FileReader();

        file.status = "loading";
        file.percent = 0;

        if (!$scope.uploads[id]) {
          $scope.uploads[id] = [];
        }

        $scope.uploads[id].push(file);

        $scope.$apply();

        r.onprogress = function(e) {
          file.progress = e;
          $scope.$apply();
        };

        r.onload = function(e) {
          var data = e.target.result;
          var fd = new FormData();
          var uri =
            "/krill/upload?assoc_operations=" +
            $scope.upload_config.associate_with_operations +
            "&assoc_plans=" +
            $scope.upload_config.associate_with_plans;
          var xhr = new XMLHttpRequest();

          file.status = "sending";
          $scope.$apply();

          xhr.open("POST", uri, true);

          xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
              var upload = AQ.Upload.record(JSON.parse(xhr.responseText));
              $scope.job.uploads.push(upload);
              file.status = "complete";
              if ($scope.upload_config.associate_with_operations) {
                aq.each($scope.job.operations, operation =>
                  operation.recompute_getter("data_associations")
                );
              }
              let step = $scope.job.backtrace.last;
              if (varname != "__generic__") {
                if (!step.response || !step.response.inputs[varname]) {
                  step.response.inputs[varname] = [];
                }
                step.response.inputs[varname].push({
                  name: upload.upload_file_name,
                  id: upload.id
                });
              }
              $scope.uploading = false;
              $scope.$apply();
            }
          };

          fd.append("file", file);
          fd.append("authenticity_token", $("#authenticity_token").val());
          fd.append("job", $scope.job.id);
          xhr.send(fd);
        };

        r.readAsBinaryString(file);
      }

      $scope.complete_upload_method = function(varname, id) {
        return function(files) {
          $scope.uploading = true;
          if (files.length != 0) {
            for (var i = 0; i < files.length; i++) {
              send_file(varname, id, files[i]);
            }
          }
        };
      };

      $scope.ok = function() {
        $scope.job.advance().then(() => {
          if (
            $scope.job.backtrace.last.timer &&
            !$scope.job.backtrace.complete
          ) {
            show_timer($scope.job.backtrace.last.timer);
          }
          $scope.job.recompute_getter("operations");
        });
      };

      $scope.pretty = function(loc) {
        return loc.replace("(eval)", "Protocol");
      };

      $scope.open_item_ui = function(id) {
        AQ.Item.where({ id: id }, { include: ["object_type", "sample"] }).then(
          items => {
            if (items.length > 0) {
              $scope.item = items[0];
              $scope.item.modal = true;
              $scope.$apply();
            } else {
              alert("Item " + id + " not found.");
            }
          }
        );
      };

      $scope.cancel = function() {
        if (confirm("Are you sure you want to cancel this job?")) {
          $scope.job.abort().then(response => {
            AQ.Job.find($scope.job_id).then(job => {
              $scope.job = job;
              $scope.zombie = false;
              $scope.$apply();
            });
          });
        }
      };

      $scope.fix = function(line) {
        return line.replace("(eval)", "protocol");
      };

      $scope.mode_class = function(mode) {
        let c = "mode-button md-squished md-raised";
        if (
          $scope.mode != "timer" &&
          mode == "timer" &&
          timer_past() &&
          timer_on() &&
          timer_blink()
        ) {
          c += " md-warn";
        } else if (mode == $scope.mode) {
          c += " md-primary";
        }
        return c;
      };

      $scope.update_job_uploads = function() {
        $scope.job.recompute_getter("uploads");
      };
    }
  ]);
})();

function open_item_ui(id) {
  try {
    angular
      .element($("#technicianCtrl"))
      .scope()
      .open_item_ui(id);
  } catch (e) {}
  try {
    let a = angular.element($("#operationTypesCtrl"));
    a.scope().open_item_ui(id);
  } catch (e) {}
  try {
    let a = angular.element($("#logCtrl"));
    a.scope().open_item_ui(id);
  } catch (e) {
    console.log(e);
  }
}

function update_job_uploads() {
  angular
    .element($("#technicianCtrl"))
    .scope()
    .update_job_uploads();
}
