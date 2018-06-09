class JobReport {

  constructor(data, status) {

    let job_report = this;

    job_report.status = status;
    job_report.selection = null;

    job_report.min = 0,
    job_report.max = 17 * 60;

    job_report.jobs = aq.collect(data,j => {
      let job = AQ.Job.record(j);  
      return job;
    });

    for ( var i=0; i<job_report.jobs.length; i++ ) {
      let job = job_report.jobs[i];
      if ( job.state.length >= 3 ) {
        job.left = this.minutes(job.state[2].time);
      } else {
        job.left = this.minutes(job.state[0].time)
      }
    }    

    job_report.jobs.sort((a,b) => a.left - b.left );

    if ( job_report.jobs.length > 0 ) {
      job_report.min = Math.floor(job_report.jobs[0].left/60)*60 - 60;
      job_report.max = Math.ceil(job_report.jobs[job_report.jobs.length-1].left/60)*60 + 60;
      job_report.selection = job_report.jobs[0];    
    }

    let top = 28;

    for ( var i=0; i<job_report.jobs.length; i++ ) {
      let job = job_report.jobs[i];
      job.top = top;
      job.height = 20; // 22 * job.operations.length - 2;
      top += 22; // 22 * job.operations.length;
      job.width = Math.max(5,this.minutes(job.updated_at) - job.left);
      let errors = aq.where(job.operations, op => op.status == "error");
      job.error_rate = errors.length / job.operations.length;
      job.color = `rgb(${255*job.error_rate},${255*(1-job.error_rate)},0)`
    }

    job_report.hour_boxes = [];

    if ( job_report.jobs.length > 0 ) {

      for ( var x = job_report.min; x < 24*60; x += 60 ) {
        job_report.hour_boxes.push({
          top: 0,
          left: x - job_report.min,
          width: 60,
          hour: x / 60 <= 12 ? x / 60 : x/60 - 12,
          height: job_report.jobs[job_report.jobs.length-1].top + 42
        })
      }

    }
    
  }

  minutes(date_string) {
    let d = new Date(date_string);
    return d.getMinutes() + 60 * d.getHours();
  }

}