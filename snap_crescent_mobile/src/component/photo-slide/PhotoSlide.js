import React, { useEffect, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import CoreStyles from '../../styles/styles';
import Loader from '../Loader';
import { getPhotoById } from '../../core/service/PhotoService';
import GestureRecognizer from 'react-native-swipe-gestures';
import { Image } from 'react-native-elements';

const initialPhotoState = {
    id: null,
    label: null,
    source: null,
    index: null,
}

function PhotoSlide(props) {

    const { navigation, route } = props;
    const { photos, selectedPhotoId } = route.params;

    const [currentPhoto, setCurrentPhoto] = useState(initialPhotoState);
    const [previousPhoto, setPreviousPhoto] = useState(initialPhotoState);
    const [nextPhoto, setNextPhoto] = useState(initialPhotoState);

    useEffect(() => {
        if (selectedPhotoId) {
            getPhotoUriById(selectedPhotoId, setCurrentPhoto);

            let previousId = null;
            let nextId = null;

            const indexOfSelectedPhoto = photos.findIndex(photo => photo.id == selectedPhotoId);

            if (indexOfSelectedPhoto == 0) { // First Image
                nextId = photos[indexOfSelectedPhoto + 1].id;
            } else if (indexOfSelectedPhoto + 1 === photos.length) { // Last Image
                previousId = photos[index - 1].id;
            }
            else {
                previousId = photos[indexOfSelectedPhoto - 1].id;
                nextId = photos[indexOfSelectedPhoto + 1].id;
            }

            getPhotoUriById(previousId, setPreviousPhoto);
            getPhotoUriById(nextId, setNextPhoto);
        }
    }, [photos, selectedPhotoId]);

    useEffect(() => {
        if (currentPhoto?.label) {
            navigation.setOptions({ title: currentPhoto.label });
        }
    }, [currentPhoto])

    const getPhotoUriById = (photoId, setPhotoCallback) => {
        if (photoId) {
            const indexOfPhoto = photos.findIndex(photo => photo.id == photoId);
            const photo = {
                id: photoId,
                index: indexOfPhoto,
                thumbnail: photos[indexOfPhoto].thumbnailSource,
                label: getPhotoLabel(photos[indexOfPhoto]),
            };

            getPhotoById(photoId).then((res) => {
                if (res) {
                    const fileReader = new FileReader();
                    fileReader.readAsDataURL(res);
                    fileReader.onload = () => {

                        photo.source = {
                            uri: fileReader.result
                        };
                        setPhotoCallback({ ...photo });
                    }
                }
            });
        } else {
            setPhotoCallback(null);
        }
    }

    const getPhotoLabel = (photo) => {
        if (photo.createdDate) {
            return new Date(photo.createdDate).toDateString();
        } else {
            return 'Photo';
        }
    }

    const handleSwipeLeft = () => {
        if (nextPhoto) {
            setPreviousPhoto(currentPhoto);
            setCurrentPhoto(nextPhoto);

            const indexOfNextPhoto = nextPhoto.index + 1;

            if (indexOfNextPhoto < photos.length) {
                handleSwipeEvent(indexOfNextPhoto, setNextPhoto);
            } else {
                setNextPhoto(null);
            }
        }
    }

    const handleSwipeRight = () => {
        if (previousPhoto) {
            setNextPhoto(currentPhoto);
            setCurrentPhoto(previousPhoto);

            const indexOfPreviousPhoto = previousPhoto.index - 1;

            if (indexOfPreviousPhoto >= 0) {
                handleSwipeEvent(indexOfPreviousPhoto, setPreviousPhoto);
            } else {
                setPreviousPhoto(null);
            }
        }
    }

    const handleSwipeEvent = (index, setPhotoCallBack) => {
        const nextPhotoId = photos[index].id;
        setPhotoCallBack({
            id: nextPhotoId,
            index,
            thumbnail: photos[index].thumbnailSource,
            label: getPhotoLabel(photos[index]),
        });
        getPhotoUriById(nextPhotoId, setPhotoCallBack);
    }

    return (
        <View style={CoreStyles.flex1}>
            <View style={styles.imageContainer}>
                <GestureRecognizer
                    onSwipeLeft={() => { handleSwipeLeft() }}
                    onSwipeRight={() => { handleSwipeRight() }}>
                    {
                        !currentPhoto?.source?.uri
                            ? <Image
                                source={currentPhoto.thumbnail}
                                style={styles.image}
                                PlaceholderContent={<Loader />} />
                            : <Image
                                source={currentPhoto.source}
                                style={styles.image}
                                PlaceholderContent={<Loader />} />
                    }
                </GestureRecognizer>
            </View>
        </View >
    )
}

const styles = StyleSheet.create({
    imageContainer: {
        flex: 1,
        justifyContent: 'center',
        alignContent: 'center'
    },
    image: {
        width: '100%',
        height: '100%',
        resizeMode: 'contain'
    }
});

export default PhotoSlide;