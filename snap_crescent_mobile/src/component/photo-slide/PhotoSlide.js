import React from 'react';
import { StyleSheet, View } from 'react-native';
import CoreStyles from '../../styles/styles';
import Loader from '../Loader';
import { downloadPhotoById, getPhotoById } from '../../core/service/PhotoService';
import GestureRecognizer from 'react-native-swipe-gestures';
import { Image } from 'react-native-elements';
import DropMenu from '../shared/drop-menu/DropMenu';
import { showToast } from '../../core/service/ToastService';

class PhotoSlide extends React.Component {

    photos = [];
    selectedPhotoId = null;
    photoRequestIntervalId = null;
    menuItems = [
        { label: 'Share', hasDivider: true, onPress: () => { } },
        { label: 'Download', onPress: () => { this.downloadPhoto(this.state.currentPhoto) } }
    ];

    constructor(props) {
        super(props);
        this.photos = props.route?.params?.photos;
        this.selectedPhotoId = props.route?.params?.selectedPhotoId;

        this.state = {
            currentPhoto: {}
        };
    }

    componentDidMount() {
        if (this.photos && this.selectedPhotoId) {
            this.getPhotoUriById(this.selectedPhotoId);
        }
    }

    componentDidUpdate() {
        if (this.state.currentPhoto?.label) {
            this.props.navigation.setOptions({
                title: this.state.currentPhoto?.label,
                headerRight: () => (
                    <DropMenu items={this.menuItems} />
                ),
            });
        }
    }

    getPhotoUriById(photoId) {
        if (photoId) {
            const indexOfPhoto = this.photos.findIndex(photo => photo.id == photoId);
            this.selectedPhotoId = photoId;
            const photo = {
                ...this.photos[indexOfPhoto],
                index: indexOfPhoto,
                label: this.getPhotoLabel(this.photos[indexOfPhoto])
            };

            this.setState({ currentPhoto: photo }, () => {
                if (this.state.currentPhoto.source?.uri) {
                    return;
                }

                if (this.photoRequestIntervalId) {
                    clearInterval(this.photoRequestIntervalId);
                }

                this.photoRequestIntervalId = setTimeout(() => {
                    getPhotoById(photoId).then((res) => {
                        if (res) {
                            if (photo.id == this.state.currentPhoto.id) {
                                photo.source = {
                                    uri: res
                                };
                                const selectedPhoto = this.photos.find(item => item.id == photo.id);
                                selectedPhoto.source = {
                                    uri: res
                                };
                                this.setState({ currentPhoto: { ...photo } });
                            }
                        }
                    });
                }, 1000);
            });

        } else {
            this.setState({ currentPhoto: null });
        }
    }

    getPhotoLabel(photo) {
        if (photo.createdDate) {
            return new Date(photo.createdDate).toDateString();
        } else {
            return 'Photo';
        }
    }

    handleSwipeLeft() {
        if (this.state.currentPhoto.index != (this.photos.length - 1)) {
            const nextPhotoId = this.photos[this.state.currentPhoto.index + 1].id;
            this.getPhotoUriById(nextPhotoId);
        }
    }

    handleSwipeRight() {
        if (this.state.currentPhoto.index != 0) {
            const previousPhotoId = this.photos[this.state.currentPhoto.index - 1].id;
            this.getPhotoUriById(previousPhotoId);
        }
    }

    downloadPhoto(photo) {
        downloadPhotoById(photo.id, { name: photo.name }).then(res => {
            showToast(`${photo.name} has been downloaded.`);
        });
    }

    render() {
        return (
            <View style={CoreStyles.flex1} >
                <View style={styles.imageContainer}>
                    <GestureRecognizer
                        onSwipeLeft={() => { this.handleSwipeLeft() }}
                        onSwipeRight={() => { this.handleSwipeRight() }}>
                        {
                            !this.state.currentPhoto?.source?.uri
                                ? <View>
                                    <View style={styles.thumbnailLoader}><Loader /></View>
                                    <Image
                                        source={this.state.currentPhoto?.thumbnailSource}
                                        style={styles.image}
                                        PlaceholderContent={<Loader />} />
                                </View>
                                : <Image
                                    source={this.state.currentPhoto?.source}
                                    style={styles.image}
                                    PlaceholderContent={<Loader />} />
                        }
                    </GestureRecognizer>
                </View>
            </View >
        );
    }
}

const styles = StyleSheet.create({
    thumbnailLoader: {
        position: 'absolute',
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        zIndex: 5
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