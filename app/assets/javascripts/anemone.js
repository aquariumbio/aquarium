class AnemoneWorker {

  constructor(id) {
    this.id = id;
  }

  retrieve() {

    let worker = this;

    return new Promise(function(resolve,reject) {

      let http = new XMLHttpRequest(); // Using raw Http request in case jquery
                                       // is not available

      http.onreadystatechange = function(e) {
        if ( this.readyState == 4 && this.status == 200 ) {
          let result = JSON.parse(this.responseText);
          if ( result.error ) {
            reject(result);
          } else {
            resolve(result);
          }
        } else if ( this.readyState == 4 && this.status != 200 ) {
          reject("HTTP Error in AnemoneWorker");
        }
      }

      http.open("GET", `/workers/${worker.id}`);
      http.send();

    });
  }

};
