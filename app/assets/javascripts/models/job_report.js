class JobReport {

  constructor(data, status, date) {

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
        job.started_at = job.state[2].time;
      } else {
        job.started_at = job.state[0].time
      }
      job.left = this.minutes(job.started_at);
      job.started_same_day = this.is_same_day(job.started_at, date);
      job.updated_same_day = this.is_same_day(job.updated_at, date);
    }    

    job_report.jobs = aq.where(job_report.jobs, job => 
      this.is_same_day(job.started_at, date) || this.is_same_day(job.updated_at, date)
    )

    // sort by start time to find mins and maxes
    job_report.jobs.sort((a,b) => a.left - b.left);

    let min_list = aq.collect(job_report.jobs, job => 
      job.started_same_day ? job.left : this.minutes(job.updated_at)
    )

    min_list.sort((a,b) => a-b);

    if ( job_report.jobs.length > 0 ) {
      job_report.min = Math.floor(min_list[0]/60)*60 - 60;
      job_report.max = Math.ceil(min_list[job_report.jobs.length-1]/60)*60 + 60;
      job_report.selection = job_report.jobs[0];    
    }

    // re-sort to deal with jobs that started on different days, for display
    job_report.jobs.sort((a,b) => {
      if ( a.started_same_day && b.started_same_day ) {
        return a.left - b.left;
      } else if ( !a.started_same_day && b.started_same_day ) {
        return this.minutes(a.updated_at) - b.left;
      } else if ( a.started_same_day && !b.started_same_day ) {
        return a.left - this.minutes(b.updated_at);
      } else {
        return this.minutes(a.updated_at) - this.minutes(b.updated_at)
      }
    });    

    let top = 28;

    for ( var i=0; i<job_report.jobs.length; i++ ) {
      let job = job_report.jobs[i];
      job.top = top;
      job.height = 20; // 22 * job.operations.length - 2;
      top += 22; // 22 * job.operations.length;
      job.width = Math.max(5,this.minutes(job.updated_at) - job.left);      
      if ( !job.started_same_day ) {
        job.width = Math.max(5,this.minutes(job.updated_at) - job_report.min);  
        job.left = 0;
      } else if ( !job.updated_same_day ) {
        job.width = Math.max(5,24*60 - job.left+5);
        job.left -= job_report.min;
      } else {
        job.left -= job_report.min;
      }
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

  is_same_day(date_string, report_date) {
    let d = new Date(date_string),
        date = new Date(report_date);
    return d.getDate() == date.getDate() && 
           d.getMonth() == date.getMonth() &&
           d.getFullYear() == date.getFullYear();
  }  

}