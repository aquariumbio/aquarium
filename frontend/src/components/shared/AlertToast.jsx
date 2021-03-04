import React, { useEffect, useState } from 'react';
import Snackbar from '@material-ui/core/Snackbar';
import MuiAlert from '@material-ui/lab/Alert';
import { makeStyles } from '@material-ui/core/styles';
import PropTypes from 'prop-types';

const useStyles = makeStyles((theme) => ({
  root: {
    width: '100%',
    '& > * + *': {
      marginTop: theme.spacing(2),
    },
  },
}));

function Alert(props) {
  // eslint-disable-next-line react/jsx-props-no-spreading
  return <MuiAlert elevation={6} variant="filled" {...props} />;
}

function raw(message) {
  return { __html: message.replace(/\n/g, '<br>') };
}

const AlertToast = (props) => {
  const { message, severity, open, setAlertProps } = props;
  const classes = useStyles();
  const [state, setState] = useState({
    open: false,
    severity: 'info',
    message: '',
  });

  // Set state from props
  useEffect(() => {
    setState({
      message,
      severity,
      open,
    });
  }, [props]);

  // Allow for manual closing
  const handleClose = (reason) => {
    if (reason === 'clickaway') {
      return;
    }

    setState({
      ...state,
      open: false,
    });

    // Clear alert props in parent to prevent the alert reopening
    setAlertProps({});
  };

  /*  message is pretty printed JSON.stringify which includes \n line breaks raw changes \n line breaks to <br>
      reaact ignores the <br> and requires us to use “dangerouslySetInnerHTML”
      TODO: render form errors inline rather than as a list in the alert */
  return (
    <div className={classes.root}>
      <Snackbar open={open} autoHideDuration={6000} onClose={handleClose}>
        <Alert onClose={handleClose} severity={severity} data-cy="alert-toast">
          <span dangerouslySetInnerHTML={raw(message)} />
        </Alert>
      </Snackbar>
    </div>
  );
};

export default AlertToast;

AlertToast.propTypes = {
  message: PropTypes.string,
  open: PropTypes.bool,
  severity: PropTypes.oneOf(['info', 'warning', 'success', 'error']),
  setAlertProps: PropTypes.func.isRequired,
};

AlertToast.defaultProps = {
  message: '',
  open: false,
  severity: 'info',
};
