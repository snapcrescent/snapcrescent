import React, { useState } from 'react';
import clsx from 'clsx';
import './Header.scss';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import InputBase from '@material-ui/core/InputBase';
import IconButton from '@material-ui/core/IconButton';
import MenuIcon from '@material-ui/icons/Menu';
import SearchIcon from '@material-ui/icons/Search';
import CloudUploadIcon from '@material-ui/icons/CloudUpload';
import ExitToAppIcon from '@material-ui/icons/ExitToApp';
import ReplayIcon from '@material-ui/icons/Replay';
import ViewModuleIcon from '@material-ui/icons/ViewModule';
import { makeStyles, useTheme } from '@material-ui/core/styles';
import { signOut } from '../../actions/AuthAction';
import { useHistory } from "react-router";
import { UploadDialog } from '../UploadDialog/UploadDialog';
import { Grid, useMediaQuery } from '@material-ui/core';


const drawerWidth = 240;

const useStyles = makeStyles((theme) => ({
  appBar: {
    background: '#15C57E',
    zIndex: theme.zIndex.drawer + 1,
    transition: theme.transitions.create(['width', 'margin'], {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.leavingScreen,
    }),
  },
  appBarShift: {
    marginLeft: drawerWidth,
    width: `calc(100% - ${drawerWidth}px)`,
    transition: theme.transitions.create(['width', 'margin'], {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.enteringScreen,
    }),
  },
  menuButton: {
    marginRight: 36,
  },
  hide: {
    display: 'none',
  },
  inputRoot: {
    color: 'inherit',
    display: 'flex'
  },
  inputInput: {
    padding: theme.spacing(1, 1, 1, 0),
    // vertical padding + font size from searchIcon
    paddingLeft: `calc(1em + ${theme.spacing(4)}px)`,
    transition: theme.transitions.create('width'),
    width: '100%',
  },
}));

export const Header = (props) => {

  const history = useHistory();
  const classes = useStyles();
  const theme = useTheme();
  const isMobileView = useMediaQuery(theme.breakpoints.down('sm'));
  const [openUploadPhotoDialog, setOpenUploadPhotoDialog] = useState(false);

  const handleDrawerOpen = () => {
    props.onMenuClick();
  }

  const signOutUser = (event) => {
    const requestObject = {};
    signOut(requestObject).then(res => {
      history.push({ pathname: '/signin' });
      localStorage.clear();
    }).catch(error => {
      console.log(error);
    });
  };

  return (
    <div>
      <AppBar
        position="fixed"
        className={clsx(classes.appBar, {
          [classes.appBarShift]: props.open,
        })}

      >
        <Toolbar>
          <Grid container>
            <Grid item>
              <IconButton
                color="inherit"
                aria-label="open drawer"
                onClick={handleDrawerOpen}
                edge="start"
                className={clsx(classes.menuButton, {
                  [classes.hide]: props.open,
                })}
              >
                <MenuIcon />
              </IconButton>
            </Grid>

            <Grid item className='center-content'>
              <Typography variant="h6" noWrap>
                Snap Crescent
              </Typography>
            </Grid>

            {!isMobileView
              ? showAppBarTools(classes, setOpenUploadPhotoDialog, signOutUser)
              : <></>
            }
          </Grid>

        </Toolbar>

      </AppBar>
      <UploadDialog
        openDialog={openUploadPhotoDialog}
        setOpenDialog={setOpenUploadPhotoDialog}
        title='Upload'
        fullScreen={true}
      ></UploadDialog>
    </div>
  )
}

function showAppBarTools(classes, setOpenUploadPhotoDialog, signOutUser) {
  return (
    <>
      <Grid item sm={4} className='center-content'>
        <div className="search">
          <div className="searchIcon">
            <SearchIcon />
          </div>
          <InputBase
            placeholder="Search…"
            classes={{
              root: classes.inputRoot,
              input: classes.inputInput,
            }}
            inputProps={{ 'aria-label': 'search' }} />
        </div>
      </Grid>
      <Grid item sm></Grid>

      <Grid item>
        <IconButton color="inherit" aria-label="reload">
          <ReplayIcon />
        </IconButton>
        <IconButton color="inherit" aria-label="toggle view">
          <ViewModuleIcon />
        </IconButton>
        <IconButton color="inherit" aria-label="upload" onClick={() => setOpenUploadPhotoDialog(true)}>
          <CloudUploadIcon />
        </IconButton>
        <IconButton color="inherit" aria-label="logout" onClick={signOutUser}>
          <ExitToAppIcon />
        </IconButton>
      </Grid>
    </>
  );
}
