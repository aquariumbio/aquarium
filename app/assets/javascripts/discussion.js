function Discussion(spec) {

  // Adjust underscore template delimiter

    _.templateSettings = {
        interpolate: /\{\{\=(.+?)\}\}/g,
        evaluate: /\{\{(.+?)\}\}/g
    };

  // set up instance variables
  
  var that = this;
  this.topic = spec.topic;

  if ( spec.klass == 'ProtocolSummary' ) { // protocols are treated differently because
    this.klass = "Protocol";               // they do not have database tables, but are instead
    this.key = "sha";                      // found in the github repo
  } else {
    this.klass = spec.klass;
    this.key = "id";
  }

  this.query = "?klass=" + this.klass + "&key=" + this.topic[this.key];

  this.button = spec.button;
  this.modal = spec.modal;

  // Associate actions with buttons 

  var button_name = 'Discuss ' + this.klass;
  if ( spec.link ) {
    button_name = spec.link;
  } 

  this.button.html(button_name).click(function() {
    that.render();   
  });

  $("#new-post-button",this.modal).click(function() {
    that.post($("#new-post-text",that.modal).val());
  }).prop("disabled",true);

  $("#new-post-text",this.modal).bind('input propertychange',function() {
    $("#new-post-button",that.modal).prop('disabled',$(this).val() == "");
  });

}

Discussion.prototype.template = function(name) {
  return _.template($('#'+name+"-template").html());
}

Discussion.prototype.render = function() {

  var that = this;

  $.ajax({
    url: "/posts.json" + that.query
  }).done(function(posts) {
    var rp = that.render_aux(posts);
    $("#posts",that.modal).empty().append(rp);
  });

}

Discussion.prototype.render_aux = function(posts) {

  var ul = $('<ul />');
  var that = this;

  for ( var i=0; i<posts.length; i++ ) {

    ul.append(this.reply_box(posts[i]));

    if ( posts[i].responses.length > 0 ) {
      ul.append($("<li />").append(that.render_aux(posts[i].responses)));
    }

  }

  return ul;

}

Discussion.prototype.reply_box = function(post) {

  var that = this;

  var li = $(this.template('post')(post));

  $("#start-reply-button",li).click(function(){
    $("#reply-area",li).css('display','block');
    $("#start-reply-button",li).css('display','none');
  });

  $("#cancel-reply-button",li).click(function(){
    $("#reply-area",li).css('display','none');
    $("#start-reply-button",li).css('display','block');        
    $("#reply-text",li).empty();
  });

  $("#send-reply-button",li).click(function(){
    $("#send-reply-button",li).prop('disabled',true);
    that.reply($("#reply-text",li).val(),post.id);
  }).prop("disabled",true);

  $("#reply-text",li).bind('input propertychange',function() {
    $("#send-reply-button",li).prop('disabled',$(this).val() == "");
  });

  return li;

}

Discussion.prototype.post = function(content) {

  var that = this;

  $.ajax({
    type: "post",
    url: "/posts.json",
    data: {data: { klass: that.klass, key: that.topic[that.key], content: content }}
  }).done(function(data) {
    $("#new-post-text",that.modal).val("");
    console.log(data);
    that.render();
  });

}

Discussion.prototype.reply = function(content,parent_id) {

  var that = this;

  $.ajax({
    type: "post",
    url: "/posts.json",
    data: {data: { parent_id: parent_id, content: content }}
  }).done(function(data) {
    console.log(data);
    that.render();
  });

}
