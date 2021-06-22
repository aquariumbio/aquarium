import { makeStyles } from '@material-ui/core/styles';

const globalUseStyles = makeStyles((theme) => ({
  flex: {
    display: '-ms-flexbox',
    // eslint-disable-next-line no-dupe-keys
    display: 'flex',
    position: 'relative',
  },
  flexWrapper: {
    padding: `0 ${theme.spacing(1)}px`,
    height: 'inherit',
  },
  /* Title row */
  flexTitle: {
    padding: `${theme.spacing(2)}px ${theme.spacing(4)}px`,
    borderBottom: '1px solid #DDD',
    fontWeight: 'bold',

    '& p': {
      fontWeight: 'bold',
      lineHeight: 1.75,
    },
  },
  flexRow: {
    padding: `${theme.spacing(2)}px ${theme.spacing(4)}px`,
    lineHeight: 1.75,
    borderBottom: '1px solid #DDD',
    '&:hover': {
      boxShadow: '0 0 3px 0 rgba(0, 0, 0, 0.8)',
    },
    '& p': {
      lineHeight: 1.75,
    },
  },
  flexRowNested: {
    padding: '2px 0',
  },
  flexCol1: {
    flex: '1 1 0',
    paddingRight: `${theme.spacing(1)}px`,
    paddingLeft: `${theme.spacing(1)}px`,
    minWidth: '0',
  },

  flexCol2: {
    flex: '2 1 0',
    paddingRight: `${theme.spacing(1)}px`,
    paddingLeft: `${theme.spacing(1)}px`,
    minWidth: '0',
  },

  flexCol3: {
    flex: '3 1 0',
    paddingRight: `${theme.spacing(1)}px`,
    paddingLeft: `${theme.spacing(1)}px`,
    minWidth: '0',
  },

  flexCol4: {
    flex: '4 1 0',
    paddingRight: `${theme.spacing(1)}px`,
    paddingLeft: `${theme.spacing(1)}px`,
    minWidth: '0',
  },

  flexColAuto: {
    width: 'auto',
    paddingRight: `${theme.spacing(1)}px`,
    paddingLeft: `${theme.spacing(1)}px`,
    minWidth: '0',
  },

  /* Use to scale and hide columns in the title row */
  flexColAutoHidden: {
    width: 'auto',
    marginRight: `${theme.spacing(1)}px`,
    paddingLeft: `${theme.spacing(1)}px`,
    minWidth: '0',
    visibility: 'hidden',
  },

  show: {
    display: 'block',
  },

  hide: {
    display: 'none',
  },

  visible: {
    visibility: 'visible',
  },

  hidden: {
    visibility: 'hidden',
  },

  relative: {
    position: 'relative',
  },

  absolute: {
    position: 'absolute',
  },

  pointer: {
    cursor: 'pointer',
  },

  wrapper: {
    padding: '0 24px',
  },

}));

export default globalUseStyles;
