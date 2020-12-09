import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Modal from '@material-ui/core/Modal';
import Backdrop from '@material-ui/core/Backdrop';
import Fade from '@material-ui/core/Fade';
import PropTypes from 'prop-types';

const useStyles = makeStyles((theme) => ({
  modal: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  paper: {
    backgroundColor: theme.palette.background.paper,
    border: '2px solid #000',
    boxShadow: theme.shadows[5],
    padding: theme.spacing(2, 4, 3),
  },
}));

const StandardModal = ({ details }) => {
  const classes = useStyles();
  const [open, setOpen] = React.useState(false);

  const handleOpen = () => {
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
  };

  return (
    <div>
      <button type="button" onClick={handleOpen}>
        {details.btnText}
      </button>
      <Modal
        aria-labelledby={`${details.htmlId}-modal`}
        aria-describedby={`${details.htmlId}-description`}
        className={classes.modal}
        open={open}
        onClose={handleClose}
        closeAfterTransition
        BackdropComponent={Backdrop}
        BackdropProps={{
          timeout: 500,
        }}
      >
        <Fade in={open}>
          <div className={classes.paper}>
            <h2 id={`${details.htmlId}-modal`}>{details.title}</h2>
            <p id={`${details.htmlId}-description`}>
              {details.message}
            </p>
          </div>
        </Fade>
      </Modal>
    </div>
  );
};

export default StandardModal;

StandardModal.propTypes = {
  details: PropTypes.shape({
    title: PropTypes.string.isRequired,
    message: PropTypes.string.isRequired,
    htmlId: PropTypes.string.isRequired,
    btnText: PropTypes.string.isRequired,
  }).isRequired,
};
