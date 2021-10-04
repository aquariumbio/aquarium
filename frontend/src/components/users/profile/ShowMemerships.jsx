import React from 'react';
import PropTypes from 'prop-types';
import Typography from '@material-ui/core/Typography';

// eslint-disable-next-line no-unused-vars, object-curly-newline
const ShowMemerships = ({ groups, setIsLoading, setAlertProps }) => {
  // eslint-disable-next-line no-unused-vars
  const unused = 'unused';

  return (
    <>
      {groups.map((group) => (
        <div>
          <Typography variant="h5">
            {group.name}
          </Typography>
          <Typography>
            {group.description}
          </Typography>
          <br />
        </div>
      ))}
    </>
  );
};

ShowMemerships.propTypes = {
  groups: PropTypes.isRequired,
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
};

export default ShowMemerships;
