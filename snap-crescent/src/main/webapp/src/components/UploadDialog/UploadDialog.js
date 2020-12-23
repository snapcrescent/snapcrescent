import React from 'react';
import './UploadDialog.scss';
import Dialog from '@material-ui/core/Dialog';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import CloseIcon from '@material-ui/icons/Close';
import CloudUploadIcon from '@material-ui/icons/CloudUpload';
import { DialogContent, makeStyles } from '@material-ui/core';
import { upload } from '../../services/UploadService';
import {showSuccess, showError} from '../../utils/ToastUtil';

const useStyles = makeStyles((theme) => ({
    appBar: {
        position: 'relative',
        background: '#15C57E'
    },
    title: {
        marginLeft: theme.spacing(2),
        flex: 1,
    },
    content: {
        textAlign: 'center'
    }
}));

export const UploadDialog = (props) => {
    const classes = useStyles();
    const { title, openDialog, fullScreen, setOpenDialog } = props;

    const uploadFile = (event) => {
        const formData = new FormData();
        for (var fileIndex = 0; fileIndex < event.target.files.length; fileIndex++) {
            formData.append("files", event.target.files[fileIndex]);    
        }
        upload(formData).then(res => {
            if(res) {
                setOpenDialog(false);
                showSuccess(res.message);
            }
        });
    }

    return (
        <div>
            <Dialog fullScreen={fullScreen} open={openDialog}>
                <AppBar className={classes.appBar}>
                    <Toolbar>
                        <IconButton edge="start" color="inherit" onClick={() => setOpenDialog(false)} aria-label="close">
                            <CloseIcon />
                        </IconButton>
                        <Typography variant="h6" className={classes.title}>
                            {title}
                        </Typography>
                    </Toolbar>
                </AppBar>
                <DialogContent dividers className={classes.content}>
                    <Typography variant="h6">
                        Please don't upload photos containing offensive content. Uploads that may contain such images will be rejected automatically.
                        Non-photographic and low-quality images require a review before they appear in search results.
                        </Typography>
                    <label htmlFor='upload' className='file-upload-button'>
                        <CloudUploadIcon className='m-r-10' /> <Typography variant="h6">Upload File</Typography>
                    </label>
                    <input type='file' onChange={uploadFile} id='upload' multiple/>
                </DialogContent>
            </Dialog>
        </div>
    )
}