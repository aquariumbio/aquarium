import createBreakpoints from '@material-ui/core/styles/createBreakpoints';
import { createMuiTheme } from '@material-ui/core/styles';

const breakpoints = createBreakpoints({});

const theme = createMuiTheme({
  palette: {
    primary: {
      light: '#6ab7ff',
      main: '#0B88FB',
      dark: '#005cc7',
      contrastText: '#fff',
    },
    disabled: '#ddd',
  },
  overrides: {
    MuiDivider: {
      root: {
        color: '#DDD',
      },
    },
    MuiAppBar: {
      colorPrimary: {
        backgroundColor: '#fff',
      },
    },
    MuiTypography: {
      body1: {
        [breakpoints.down('lg')]: {
          fontSize: '0.875rem',
        },
      },
      body2: {
        [breakpoints.down('lg')]: {
          fontSize: '0.75rem',
        },
      },
    },
    MuiListItem: {
      gutters: {
        paddingLeft: '10px',
      },
    },
    MuiListSubheader: {
      gutters: {
        paddingLeft: '10px',
      },
    },
  },
});

export default theme;
