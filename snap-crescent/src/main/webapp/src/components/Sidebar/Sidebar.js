import React from 'react';
import './Sidebar.scss';
import clsx from 'clsx';
import { makeStyles, useTheme } from '@material-ui/core/styles';
import Drawer from '@material-ui/core/Drawer';
import List from '@material-ui/core/List';
import CssBaseline from '@material-ui/core/CssBaseline';
import Divider from '@material-ui/core/Divider';
import IconButton from '@material-ui/core/IconButton';
import ChevronLeftIcon from '@material-ui/icons/ChevronLeft';
import ChevronRightIcon from '@material-ui/icons/ChevronRight';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import PhotoIcon from '@material-ui/icons/Photo';
import FavoriteIcon from '@material-ui/icons/Favorite';
import LockIcon from '@material-ui/icons/Lock';
import MovieIcon from '@material-ui/icons/Movie';
import { Header } from '../Header/Header';
import { Link } from 'react-router-dom';

const drawerWidth = 240;
const bgImgUrl = `https://images.unsplash.com/photo-1564352969906-8b7f46ba4b8b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1534&q=80`;

const useStyles = makeStyles((theme) => ({
  drawer: {
    width: drawerWidth,
    flexShrink: 0,
    whiteSpace: 'nowrap',
  },
  drawerOpen: {
    width: drawerWidth,
    transition: theme.transitions.create('width', {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.enteringScreen,
    }),
    backgroundImage: `url(${bgImgUrl})`,
    backgroundSize: 'cover'
  },
  drawerClose: {
    transition: theme.transitions.create('width', {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.leavingScreen,
    }),
    overflowX: 'hidden',
    width: theme.spacing(7) + 1,
    [theme.breakpoints.up('sm')]: {
      width: theme.spacing(9) + 1,
    },
    backgroundImage: `url(${bgImgUrl})`,
    backgroundSize: 'cover'
  },
  toolbar: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'flex-end',
    padding: theme.spacing(0, 1),
    // necessary for content to be below app bar
    ...theme.mixins.toolbar,
  },
  listItemText: {
    color: '#fff',
    fontWeight: 'bold'
  }
}));

export const Sidebar = () => {
  const classes = useStyles();
  const theme = useTheme();
  const [open, setOpen] = React.useState(false);

  const handleDrawerOpen = () => {
    setOpen(true);
  };

  const handleDrawerClose = () => {
    setOpen(false);
  };

  const sideNavItems = [
    {
      title: 'Photos',
      icon: <PhotoIcon />,
      url: '/home/photos'
    },
    {
      title: 'Favorites',
      icon: <FavoriteIcon />,
      url: '/home/favorites'
    },
    // {
    //   title: 'Private',
    //   icon: <LockIcon />,
    //   url: '/home/private'
    // },
    {
      title: 'Videos',
      icon: <MovieIcon />,
      url: '/home/videos'
    },
  ];
  return (
    <div>
      {/* <CssBaseline /> */}
      <Header open={open} onMenuClick={handleDrawerOpen} />
      <Drawer
        variant="permanent"
        className={clsx(classes.drawer, {
          [classes.drawerOpen]: open,
          [classes.drawerClose]: !open,
        })}
        classes={{
          paper: clsx({
            [classes.drawerOpen]: open,
            [classes.drawerClose]: !open,
          }),
        }}
      >
        <div className={classes.toolbar}>
          <IconButton onClick={handleDrawerClose}>
            {theme.direction === 'rtl' ? <ChevronRightIcon /> : <ChevronLeftIcon />}
          </IconButton>
        </div>
        <Divider />
        <List>
          {sideNavItems.map((item, index) => (
            <Link to={item.url} key={index} className="sidebar-link">
              <ListItem button>
                <ListItemIcon className='primary-color'>{item.icon}</ListItemIcon>
                <ListItemText classes={{primary: classes.listItemText}} primary={item.title} />
              </ListItem>
            </Link>
          ))}
        </List>
      </Drawer>
    </div>
  );
}
