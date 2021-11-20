import { useSelector } from 'react-redux';
import './Loader.scss';
import Backdrop from '@material-ui/core/Backdrop';
import CircularProgress from '@material-ui/core/CircularProgress';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles(() => ({
    backdrop: {
      zIndex: 9999,
      color: '#ffffff',
    },
  }));

export const Loader = () => {
    const classes = useStyles();

    const loading = useSelector(state => state.loading);
    
    return(
        <div className="loader">
            <Backdrop className={classes.backdrop} open={loading > 0}>
                <CircularProgress color="inherit" />
            </Backdrop>
        </div>
        
    );
}