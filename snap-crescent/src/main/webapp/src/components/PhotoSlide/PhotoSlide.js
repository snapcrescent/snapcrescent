import React, { useState, useEffect, useRef } from 'react';
import Dialog from '@material-ui/core/Dialog';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';
import { DialogContent, makeStyles, Grid } from '@material-ui/core';
import { getById } from '../../services/PhotoService';
import { ArrowBack, ArrowForward } from '@material-ui/icons';

const useStyles = makeStyles((theme) => ({
    appBar: {
        position: 'relative',
        background: '#000000'
    },
    content: {
        textAlign: 'center',
        background: '#000000',
        color: '#ffffff',
        overflow: 'hidden'
    },
    image: {
        maxWidth: 1200,
        maxHeight: 800,
        width: 'auto',
        height: 'auto'
    },
    arrorBack: {
        position: 'absolute',
        left: 0,
        top: '50%',
        bottom: '50%'
    },
    arrorForward: {
        position: 'absolute',
        right: 0,
        top: '50%',
        bottom: '50%'
    }
}));

const useKey = (key, cb) => {

    const callbackRef = useRef(cb);


    useEffect(() => {
        callbackRef.current = cb;
    });
    useEffect(() => {
        const _handleKeyDown = (event) => {
            if (event.keyCode === key) {
                callbackRef.current(event);
            }
        }

        document.addEventListener("keydown", _handleKeyDown);
        return () => document.removeEventListener("keydown", _handleKeyDown);
    }, key)
}
export const PhotoSlide = (props) => {

    const classes = useStyles();

    const { openDialog, fullScreen, setOpenDialog, selectedId, setSelectedId, photos, totalElements, page, setPage } = props;

    const [previousPhoto, setPreviousPhoto] = useState(null);
    const [currentPhoto, setCurrentPhoto] = useState(null);
    const [nextPhoto, setNextPhotos] = useState(null);

    useEffect(() => {
        if (selectedId) {
            getPhoto(selectedId, setCurrentPhoto);
            let previousId = null;
            let nextId = null;

            photos.map((photo, index) => {
                if (photo.id.value === selectedId) {
                    if (index === 0) { // First Image
                        nextId = photos[index + 1].id.value;
                    } else if (index + 1 === photos.length) { // Last Image
                        previousId = photos[index - 1].id.value;
                    }
                    else {
                        previousId = photos[index - 1].id.value;
                        nextId = photos[index + 1].id.value;
                    }
                }
            });

            getPhoto(previousId, setPreviousPhoto);
            getPhoto(nextId, setNextPhotos);
        }
    }, [selectedId, photos]);
    const getPhoto = (id, setPhoto) => {
        if (id) {
            getById(id).then(res => {
                const url = URL.createObjectURL(new Blob([res]));
                setPhoto({ id, url });
            });
        } else {
            setPhoto(null);
        }
    }

    const handleNext = () => {

        if (!nextPhoto) {
            return;
        }

        setPreviousPhoto(currentPhoto);
        setCurrentPhoto(nextPhoto);

        let nextId = null;
        photos.map((photo, index) => {
            if (photo.id.value === nextPhoto.id) {
                if (index + 1 === photos.length) { // Last Image
                    if (photos.length < totalElements) {
                        setPage(page + 1);
                        setSelectedId(photo.id.value);
                    } else {
                        setNextPhotos(null);
                    }
                }
                else {
                    nextId = photos[index + 1].id.value;
                }
            }
        });

        getPhoto(nextId, setNextPhotos);
    }

    const handlePrevious = () => {

        if (!previousPhoto) {
            return;
        }
        setNextPhotos(currentPhoto);
        setCurrentPhoto(previousPhoto);

        let previousId = null;
        photos.map((photo, index) => {
            if (photo.id.value === previousPhoto.id) {
                if (index === 0) { // First Image
                    setPreviousPhoto(null);
                }
                else {
                    previousId = photos[index - 1].id.value;
                }
            }
        });
        getPhoto(previousId, setPreviousPhoto);
    }

    const handleClose = () => {
        setSelectedId(null);
        setOpenDialog(false);
        setCurrentPhoto(null);
    }

    useKey(37, handlePrevious);
    useKey(39, handleNext);

    return (
        <div>
            <Dialog fullScreen={fullScreen} open={openDialog}>
                <AppBar className={classes.appBar}>
                    <Toolbar>
                        <Grid item md={12} className="text-right">
                            <IconButton edge="start" color="inherit" onClick={handleClose} aria-label="close">
                                <CloseIcon />
                            </IconButton>
                        </Grid>
                    </Toolbar>
                </AppBar>
                <DialogContent dividers className={classes.content}>
                    <IconButton
                        className={classes.arrorBack}
                        color="inherit"
                        aria-label="Previous"
                        onClick={handlePrevious}
                        disabled={!previousPhoto}
                    >
                        <ArrowBack />
                    </IconButton>
                    <img src={currentPhoto?.url} alt="Image" className={classes.image} />
                    <IconButton
                        className={classes.arrorForward}
                        color="inherit"
                        aria-label="Next"
                        onClick={handleNext}
                        disabled={!nextPhoto}
                    >
                        <ArrowForward />
                    </IconButton>
                </DialogContent>
            </Dialog>
        </div>
    )
}