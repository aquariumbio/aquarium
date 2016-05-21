
function RepoListing ( repos, highlight, from ) {

  this.from = from;
  var that = this;

  for( var i = repos.children.length - 1; i >= 0; i-- ) {

    var repo_name = repos.children[i].data;
    var repo_info = repos.children[i].info;

    console.log(repos.children[i]);

    if ( ! $.cookie('open-repo-directories') ) {
      $.cookie('open-repo-directories',JSON.stringify("[]"),{ path: '/' });
    }

    // Add navigation pill
    var a = $("<a id='"+repo_name+"_li' href='#"+repo_name+"_pane' data-toggle='pill'>"+repo_name+"</a>");

    (function(repo_name) {
      a.click(function(){
        $.cookie('current-repo',repo_name,{ path: '/' });
      });
    })(repo_name);

    var li = $("<li></li>").append(a);
    $('#nav').append(li);

    // Add pane content
    var pane = $("<div class='pill-pane row-fluid' id='"+repo_name+"_pane'></div>");
    var info = $("<div class='span3 well repo-info'></div>")
    .append("<h3>"+repo_name+"</h3>")
    .append("<h4>Latest update:</h4>")
    .append("<p><b>" + repo_info.message + "</b></p>")
    .append("<p>" + (new Date(repo_info.date)).toLocaleString() + "</p>")
    .append("<p>by " + repo_info.who + "</p>");

    var dir = $("<div class='span9'></div>");

    pane.append(info).append(dir);

    $('#content').append(pane);

    var list = $("<ul></ul>").addClass('repo-list').addClass('json_list');
    dir.append(list);

    this.mkdir(repo_name,list,repos.children[i].children);

    var update_button = $("<button class='btn btn-small repo-update'>Update</button>");

    (function() {
      var name = repo_name;
      update_button.click(function() {
        $('#myModal').modal();
        that.close_repo_directories(name);
        window.location="/repo/pull?name=" + name;
      });
    })();

    info.append(update_button);

  }

  if ( ! $.cookie('current-repo') ) {
    $.cookie('current-repo',highlight,{ path: '/' });
  }

  $(function () {
    $('#'+$.cookie('current-repo')+'_li').tab('show');
  })



}

RepoListing.prototype.save_path_info_to_cookie = function(path,status) {

  var paths = JSON.parse ( $.cookie('open-repo-directories') );

  if ( status ) { // add path to list
    paths.push(path);
  } else { // remove path from list
    paths.splice( paths.indexOf(path), 1 );
  }

  $.cookie('open-repo-directories',JSON.stringify(paths),{ path: '/' });

}

RepoListing.prototype.is_open = function(path) {

  var paths = JSON.parse ( $.cookie('open-repo-directories') );
  return ( paths.indexOf(path) >= 0 );

}

RepoListing.prototype.close_repo_directories = function(name) {

  var paths = JSON.parse ( $.cookie('open-repo-directories') );
  var newpaths = [];
  for ( var i=0; i<paths.length; i++ ) {
    if ( ! paths[i].match ( "^" + name ) ) {
      newpaths.push(paths[i]);
    }
  }
  
  $.cookie('open-repo-directories',JSON.stringify(newpaths),{ path: '/' });

}

RepoListing.prototype.mkdir = function(path,tag,children) {

  var that = this;

  for(var i=0; i<children.length; i++) {

    if(typeof children[i] == "string") { // it's a file

      if ( children[i].match ( /\.rb$/ ) ) {
        tag.append($("<li></li>").append("<a href=/krill/arguments?path="+path+"/"+children[i]+this.from+">"+children[i]+"</a>"));
      } else {
        tag.append($("<li></li>").append("<a href=/repo/get?path="+path+"/"+children[i]+this.from+">"+children[i]+"</a>"));
      }

    } else { // it's a directory

      (function() { // create a closure so the click function works

        var dirname = children[i].data;
        var newpath = path+"/"+dirname;
        var contents = children[i].children;

        var sublist = $("<ul id=" + dirname + "></ul>").addClass('repo-list').addClass('json_list');

        if ( that.is_open(newpath) ) {
          sublist.css('display','block');
        } else {
          sublist.css('display','none');
        }

        var link = $("<a href='#'>" + dirname + "</a>");
        var name = $("<li></li>").addClass('repo-dirname').append(link).append(sublist);

        link.click(function(e){
          e.preventDefault(); // prevents window from scrolling when directory name is clicked
          if ( sublist.css('display') == 'none' ) {
            sublist.css('display','block');
            that.save_path_info_to_cookie(newpath,true);
          } else {
            sublist.css('display','none');
            that.save_path_info_to_cookie(newpath,true);            
          }
        });       

        tag.append(name);
        that.mkdir(newpath,sublist,contents);

      })();

    }
  }

}

