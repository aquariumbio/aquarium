
function Aq() {
  _.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
  };
}

Aq.prototype.url_params = function() {
  var query = window.location.search.split('?');
  var result = {};
  if ( query.length == 2 ) {
    var parts = query[1].split('&');
    var result = {};
    aq.each(parts,part => {
      result[part.split('=')[0]] = part.split('=')[1];
    });
  } 
  return result;
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

Aq.prototype.each = function(array,f) {

  if ( array ) {
    for ( var i=0; i<array.length; i++ ) {
      f(array[i],i);
    }
  }
  return this;
}

Aq.prototype.each_in_reverse = function(array,f) {

  if ( array ) {
    for ( var i=array.length-1; i>=0; i-- ) {
      f(array[i],i);
    }
  }
  return this;
}

Aq.prototype.uniq = function(array) {

  var result = [];

  if ( array ) {
    for ( var i=0; i<array.length; i++ ) {
      if ( result.indexOf(array[i]) < 0 ) {
        result.push(array[i]);
      }
    }
  }

  return result;

}

Aq.prototype.collect = function(array,f) {
  var result = [];
  if ( array ) {
    for ( var i=0; i<array.length; i++ ) {
      result.push(f(array[i],i));
    }
  }
  return result;
}

Aq.prototype.sum = function(array,f) {
  var result = 0;
  if ( array ) {
    for ( var i=0; i<array.length; i++ ) {
      result += f(array[i],i);
    }
  }
  return result;
}

Aq.prototype.where = function(array,f) {
  var result = [];
  if (array) {
    for ( var i=0; i<array.length; i++ ) {
      if ( f(array[i]) ) {
        result.push(array[i]);
      }
    }
  }
  return result;
}

Aq.prototype.find = function(array,f) {
  var results = this.where(array,f);
  if ( results.length > 0 ) {
    return results[0];
  } else {
    return undefined;
  }
}

Aq.prototype.remove = function(array,element) {
  var i = array.indexOf(element);
  if ( i > -1 ) {
    array.splice(i,1);
  }
  return array;
}

Aq.prototype.range = function(n) {
  var result = [];
  for ( var i=0; i<n; i++ ) {
    result.push(i);
  }
  return result;
}

Aq.prototype.random_int = function(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

Aq.prototype.random_list = function(min_length,max_length,min_val,max_val) {
  var len = this.random_int(min_length,max_length);
  var that = this;
  return this.collect ( this.range(len), function(i) {
    return that.random_int(min_val,max_val);
  });
}

Aq.prototype.matrix = function(n,m,el) {
  var rows = [];
  if ( !el ) {
    el = null;
  }
  for ( var i=0; i<n; i++ ) {
    var col = [];
    for ( var j=0; j<m; j++ ) {
      col.push(el);
    }
    rows.push(col);
  }
  return rows;
}

Aq.prototype.pluck = function(obj,fields) {
  var result = {};
  o.each(fields,function(f) {
    result[f] = obj[f];
  });
  return result;
}

Aq.prototype.currency = function(num) {
  return '$' + parseFloat(num, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString();
}

Aq.prototype.query = function() {

  var query_string = window.location.search.split('?')[1];
  var o = {};

  if ( query_string ) {
    
    aq.each(query_string.split('&'), function(p) { 
      var key = p.split("=")[0],
          val = p.split("=")[1];
      o[key] = val;
    });
    
  } 

  return o;

}

aq = new Aq();
