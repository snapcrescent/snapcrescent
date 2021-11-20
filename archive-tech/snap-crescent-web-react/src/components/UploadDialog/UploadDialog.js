import React, { useState } from 'react';
import './UploadDialog.scss';
import Dialog from '@material-ui/core/Dialog';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import CloseIcon from '@material-ui/icons/Close';
import CloudUploadIcon from '@material-ui/icons/CloudUpload';
import { DialogContent, Grid, LinearProgress, makeStyles } from '@material-ui/core';
import * as uploadService from '../../services/UploadService';
import {showSuccess} from '../../utils/ToastUtil';
import { useHistory } from "react-router";

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
    },
    progressBarRoot: {
        height: '10px',
        width: '80%'
    },
    primaryColor: {
        backgroundColor: '#15C57E'
    }
}));

export const UploadDialog = (props) => {

    const history = useHistory();

    const [uploadPercent, setUploadPercent] = useState(0);
    const classes = useStyles();
    const { title, openDialog, fullScreen, setOpenDialog } = props;

    const uploadFile = (event) => {
        const formData = new FormData();
        for (var fileIndex = 0; fileIndex < event.target.files.length; fileIndex++) {
            formData.append("files", event.target.files[fileIndex]);    
        }

        const options = {
            onUploadProgress: (progressEvent) => {
                const { loaded, total } = progressEvent;
                const percent = Math.floor((loaded * 100) / total);
                console.log(percent);
                if(percent < 100) {
                    setUploadPercent(percent);
                } else {
                    setUploadPercent(95);
                }
            }
        }

        uploadService.upload(formData, options, false).then(res => {
            if(res) {
                setUploadPercent(100);
                setTimeout(() => {
                    setUploadPercent(0);
                    showSuccess(res.message);
                    history.go(0);
                }, 1000);
            } else {
                setUploadPercent(0);
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
                    <Grid container className='grid-container'>
                        <Grid item className="center-content">
                            {uploadPercent > 0 ? 
                                <LinearProgress 
                                    variant="determinate" 
                                    value={uploadPercent}
                                    classes={{root: classes.progressBarRoot, bar: classes.primaryColor}} 
                                /> : <></>}
                        </Grid>
                    </Grid>
                    <Grid container className='grid-container'>
                        <Grid item>
                            <label htmlFor='upload' className='file-upload-button'>
                                <CloudUploadIcon className='m-r-10' /> <Typography variant="h6">Upload File</Typography>
                            </label>
                            <input type='file' onChange={uploadFile} id='upload' accept="image/*" multiple/>
                        </Grid>
                    </Grid>
                </DialogContent>
            </Dialog>
        </div>
    )
}