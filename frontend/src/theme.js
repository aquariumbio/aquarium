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
    action: {
      selected: 'rgba(64, 222, 253, 0.13)',
      disabled: '#ddd',
    },
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
    MuiIconButton: {
      root: {
        padding: 0,
      },
    },
  },
});

export default theme;
