function Aq() {
  _.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
  };
}

Aq.prototype.template = function(name,args) {
  return $(_.template($('#'+name).html())(args));
}

Aq.prototype.link = function(href,text) {
  return "<a target=_top href='" + href + "'>" + text + "</a>";
}

Aq.prototype.job_link = function(jid) {
  return this.link("/jobs/" + jid,jid);
}

Aq.prototype.metacol_link = function(mid) {
  return this.link("/metacols/" + mid,mid);
}

Aq.prototype.user_link = function(uid,login) {
  if ( login ) {
    return this.link("/users/" + uid,login);
  } else {
    return "-";
  }
}

Aq.prototype.start_link = function(jid,body) {
  return this.link("/users/" + uid,login);
}

Aq.prototype.group_link = function(gid,name) {
  return this.link("/groups/" + gid,name);
}

Aq.prototype.capitalize = function(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

Aq.prototype.filename = function(path) {
  return path.split('/').slice(-1)[0];
}

Aq.prototype.nice_time = function(date,seconds) {

  var h = date.getHours();
  var m = date.getMinutes();
  var ap = h >= 12 ? 'pm' : 'am';
  h = h%12;
  h = h ? h : 12;

  m = m < 10 ? '0'+m : m;

  var s;
  if ( seconds ) {
    s = date.getSeconds();
    s = s < 10 ? '0'+s : s;
    s = ':' + s;
  } else {
    s = "";
  }
  
  return h + ":" + m + s + " " + ap;

}

Aq.prototype.nice_date = function (date) {

  var time = this.nice_time(date,true);
  var days = [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ];

  return  days[date.getDay()] + ' ' + date.toLocaleDateString() + ', ' + time;

}

Aq.prototype.delete_from_array = function (arr, el) {
  arr.splice( $.inArray(el, arr), 1 );
}

Aq.prototype.rand_string = function(n) {
  return Array.apply(0, Array(n)).map(function() {
    return (function(charset){
        return charset.charAt(Math.floor(Math.random() * charset.length))
    }('abcdefghijklmnopqrstuvwxyz'));
  }).join('');
}

// Aq.prototype.change_url = function(title, url) {
//   if (typeof (history.pushState) != "undefined") {
//       var obj = { Title: title, Url: url };
//       history.pushState(obj, obj.Title, obj.Url);
//   } else {
//       alert("Browser does not support HTML5.");
//   }
// }

aq = new Aq();