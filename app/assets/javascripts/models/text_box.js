class TextBoxAnchor {
  constructor(x,y) {
    this.x = x;
    this.y = y;
  }
  get record_type() {
    return "TextBoxAnchor";
  }  
}

class TextBox {

  constructor() {
    this.markdown = "Put any **markdown** code here.";
    if ( !this.constructor.next_position ||
         this.constructor.next_position > 300 ) {
      this.constructor.next_position = 0;
    }
    this.constructor.next_position += 10;
    this.x = 100 + this.constructor.next_position;
    this.y = 100 + this.constructor.next_position;
    this.anchor = new TextBoxAnchor(200,100);
  }

  from_object(box) {
    this.x = box.x;
    this.y = box.y;
    this.markdown = box.markdown;
    this.anchor = new TextBoxAnchor(box.anchor.x, box.anchor.y);
    return this;
  }

  get record_type() {
    return "TextBox";
  }

  get width() {
    return this.anchor.x;
  }

  get height() {
    return this.anchor.y;
  }

  get rendered_content() {
    let box = this;
    let md = window.markdownit();
    return AQ.sce.trustAsHtml(md.render(box.markdown));
  }

  serialize() {
    let box = this;
    return {
      x: box.x,
      y: box.y,
      anchor: { x: box.anchor.x, y: box.anchor.y },
      markdown: box.markdown
    }
  }

}