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
  return this.link("/users/" + uid,login);
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

Aq.prototype.nice_time = function(date) {

  var h = date.getHours();
  var m = date.getMinutes();
  var ap = h >= 12 ? 'pm' : 'am';
  h = h%12;
  h = h ? h : 12;

  m = m < 10 ? '0'+m : m;

  return h + ":" + m + " " + ap;

}

aq = new Aq();