
function ItemSelector ( root_tag, item_tag ) {

  this.root_tag = root_tag;
  this.root_el = document.getElementById ( root_tag );

  this.item_tag = item_tag;
  this.item_el = document.getElementById ( item_tag );

  this.showing_active_item = false;
  
  var html  = "<div class='row-fluid select-root'>";
      html +=   "<div class='span2 select-column'><h1>Type</h1><ul id='select-types' class='plain'></ul></div>";
      html +=   "<div class='span3 select-column'><h1>Project</h1><ul id='select-projects' class='plain'></ul></div>";
      html +=   "<div class='span2 select-column'><h1>Sample</h1><ul id='select-samples' class='plain'></ul></div>";
      html +=   "<div class='span3 select-column'><h1>Container</h1><ul id='select-containers' class='plain'></ul></div>";
      html +=   "<div class='span2 select-column'><h1>Item</h1><ul id='select-items' class='plain'></ul></div>";
      html += "</div>"

  this.root_el.innerHTML = html;

  this.types      = document.getElementById('select-types');
  this.projects   = document.getElementById('select-projects');
  this.samples    = document.getElementById('select-samples');
  this.containers = document.getElementById('select-containers');
  this.items      = document.getElementById('select-items');
  
}

ItemSelector.prototype.show_entry = function(category,name,selection) {

  var li = document.createElement("li");

  if ( name == selection ) {
    li.innerHTML = "<span class='select-link selected'>"+name+"</span>";
  } else {
    li.innerHTML = "<span class='select-link'>"+name+"</span>";
  }

  category.appendChild(li);

  return li;

}

ItemSelector.prototype.show_types = function(type) {

  var that = this;
  this.types.innerHTML = "";
  this.projects.innerHTML = "";
  this.samples.innerHTML = "";
  this.containers.innerHTML = "";
  this.items.innerHTML = "";

  for ( var st in samples ) {

    var li = this.show_entry ( this.types, st, type );

    (function(st) {
      li.addEventListener('click', function() {
        that.show_types(st);
        that.show_projects(st,'');
      });
    })(st);
 
  }

}

ItemSelector.prototype.show_projects = function(type,project) {

  var that = this;
  this.projects.innerHTML = "";
  this.samples.innerHTML = "";
  this.containers.innerHTML = "";
  this.items.innerHTML = "";

  for ( var p in samples[type] ) {

    var li = this.show_entry ( this.projects, p, project );

    (function(p) {
      li.addEventListener('click', function() {
        that.show_projects(type,p);
        that.show_samples(type,p,'');
      });
    })(p);

  }

}

ItemSelector.prototype.show_samples = function(type,project,sample) {

  var that = this;
  this.samples.innerHTML = "";
  this.containers.innerHTML = "";
  this.items.innerHTML = "";

  for ( var s in samples[type][project] ) {

    var li = this.show_entry ( this.samples, s, sample );

    (function(s) {
      li.addEventListener('click', function() {
        that.show_samples(type,project,s);
        that.show_containers(type,project,s,'');
      });
    })(s);

  }

}

ItemSelector.prototype.show_containers = function(type,project,sample,container) {

  var that = this;
  this.containers.innerHTML = "";
  this.items.innerHTML = "";

  for ( var c in samples[type][project][sample] ) {

    var li = this.show_entry ( this.containers, c, container );

    (function(c) {
      li.addEventListener('click', function() {
        that.show_containers(type,project,sample,c);
        that.show_items(type,project,sample,c,'');
      });
    })(c);

  }

}

ItemSelector.prototype.show_items = function(type,project,sample,container,item) {

  var that = this;
  this.items.innerHTML = "";

  choices = samples[type][project][sample][container];

  for ( var i in choices ) {

    var li = this.show_entry ( this.items, i, item );

    if ( i == item ) {
	this.show_item_info(sample, container, i,choices[i]);
    }

    (function(i) {
      li.addEventListener('click', function() {
        that.show_items(type,project,sample,container,i);
      });
    })(i);

  }

  this.current_selection = { type: type, project: project, sample: sample, container: container, item: item };

  // New item button
  li = document.createElement('li');

  b = document.createElement('button');
  b.innerHTML = 'new';
  b.className = 'btn btn-mini';
  b.addEventListener('click', this.new_item_callback );

  li.appendChild(b);
  that.items.appendChild(li);

}

ItemSelector.prototype.select = function(type,project,sample,container,item) {

  this.show_types(type);
  this.show_projects(type,project);
  this.show_samples(type,project,sample);
  this.show_containers(type,project,sample,container);
  this.show_items(type,project,sample,container,item);

}

ItemSelector.prototype.show_item_info = function( sample, container, id, details ) {

    var html = "<h4>Item <a href='/items/" + id + "'>" + id + "</a> Details</h4>";
    html += "<h4>" + sample + " / " + container + "</h4>";

    html += "<ul>";

    for ( var key in details ) {
        if ( key == 'data' ) {
  	  html += "<li>" + key + ": " + details[key] + "</li>";
        }
    }
    html += "</ul>";

    this.item_el.innerHTML = html;
    this.showing_active_item = true;

}

ItemSelector.prototype.clear_item_info = function() {

    this.item_el.innerHTML = ""
    this.showing_active_item = false;

    var lis = this.items.getElementsByTagName('span');
    for ( var i=0; i<lis.length; i++ ) {
      lis[i].className = 'select-link';
    }

}

function hash2query(x) {
  var s = []; 
  for (var k in x ) { 
    s.push(k+'='+x[k]); 
  }
  return s.join('&');
}