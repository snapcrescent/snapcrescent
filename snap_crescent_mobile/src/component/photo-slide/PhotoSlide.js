import React, { useEffect, useState } from 'react';
import { ActivityIndicator, Modal, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { Image } from 'react-native-elements';
import { getImageById } from '../../core/service/ImageService';
import { showToast } from '../../core/service/ToastService';
import coreStyles from '../../styles/styles';
import Loader from '../Loader';
import FontAwesome5 from 'react-native-vector-icons/FontAwesome5';

const initialState = {
    imagesToDisplay: [],
    selectedImage: null,
    showPhotoSlide: false
};

function PhotoSlide(props) {

    const { images, idFieldKey, selectedImage, showPhotoSlide, onClose } = props;
    const [state, setState] = useState(initialState);

    useEffect(() => {
        if (showPhotoSlide) {
            const selectedImg = selectedImage ? selectedImage : images[0];
            setState({ imagesToDisplay: images, selectedImage: selectedImg, showPhotoSlide: showPhotoSlide });
        } else {
            setState(initialState);
        }

    }, [images, selectedImage, idFieldKey, showPhotoSlide]);

    useEffect(() => {
        if (state.showPhotoSlide) {
            getImage(selectedImage[idFieldKey]);
        }
    }, [state.showPhotoSlide]);

    const closePhotoSlide = () => {
        setState({ ...state, showPhotoSlide: false });
        if (onClose) {
            onClose();
        }
    };

    const getImage = (imageId) => {
        getImageById(imageId).then(res => {
            if (res) {
                const fileReader = new FileReader();
                fileReader.readAsDataURL(res);
                fileReader.onload = () => {
                    const selectedImg = state.selectedImage;
                    selectedImg.source = {
                        uri: fileReader.result
                    };
                    const images = state.imagesToDisplay;
                    setState({ selectedImage: selectedImg, imagesToDisplay: images, showPhotoSlide });
                };
            } else {
                showToast('Unable to get Image');
            }
        });
    };

    return (
        <View style={coreStyles.flex1}>
            <Modal transparent={true} visible={state.showPhotoSlide}>
                <View style={styles.modalContainer}>
                    <View style={styles.modalInnerContainer}>
                        <View style={{ alignItems: 'flex-end' }}>
                            <TouchableOpacity onPress={() => { closePhotoSlide() }}>
                                <FontAwesome5 name="times" style={styles.closeIcon} />
                            </TouchableOpacity>
                        </View>
                        <View style={styles.imageContainer}>
                            {
                                !state.selectedImage?.source
                                    ? <Loader />
                                    : <View style={styles.imageContainer}>
                                        <Image
                                            source={state.selectedImage.source}
                                            PlaceholderContent={<ActivityIndicator />}
                                            style={styles.image}>
                                        </Image>
                                    </View>
                            }
                        </View>
                    </View>
                </View>
            </Modal >
        </View >
    )
}

const styles = StyleSheet.create({
    modalContainer: {
        flex: 1,
        backgroundColor: "#000000aa"
    },
    modalInnerContainer: {
        flex: 1,
        margin: 5,
        borderRadius: 5
    },
    closeIcon: {
        fontSize: 24,
        color: '#ffffff'
    },
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