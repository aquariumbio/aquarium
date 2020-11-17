import React from 'react';
import PropTypes from 'prop-types';
import Typography from '@material-ui/core/Typography';

const SampleTypeField = (props) => {
  const { styles } = props;

  return (
    <>
      <Typography className={styles.inputName}>
        Name
      </Typography>
      <Typography>
        Type
      </Typography>
      <Typography>
        Required?
      </Typography>
      <Typography>
        Array?
      </Typography>
      <Typography>
        Sample Options (If type=&lsquo;sample&lsquo;)
      </Typography>
      <Typography>
        Choices (Comma separated. Leave blank for unrestricted value).
      </Typography>
    </>
  );
};

SampleTypeField.propTypes = {
  styles: PropTypes.shape({
    // eslint-disable-next-line react/forbid-prop-types
    inputName: PropTypes.object,
  }).isRequired,
};
export default SampleTypeField;
