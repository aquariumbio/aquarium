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

Aq.prototype.user_link = function(uid,login) {
  return this.link("/users/" + uid,login);
}

Aq.prototype.group_link = function(gid,name) {
  return this.link("/groups/" + gid,name);
}

Aq.prototype.capitalize = function(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

aq = new Aq();