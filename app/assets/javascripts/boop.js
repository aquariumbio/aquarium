function boop() {
    divStyle = {
        color: 'white',
        
    };
    contStyle = {
        display: 'flex',
        
    }
      
    return (
        createElement(
            'div', 
            { 
                className: 'assigned_job_table_title fflex_resp tech_table_title',
                contStyle 
            },
            createElement(
                'button',
                { 
                    onClick: () => {},
                    id: 'ready_jobs_btn',
                    className: 'view_select_btn', 
                },
                'BOOP'
            ),
            createElement(
                'div',
                {divStyle},
                '#'
            ),
        )
    )
}