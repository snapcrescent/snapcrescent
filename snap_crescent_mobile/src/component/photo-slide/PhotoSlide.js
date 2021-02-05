import React from 'react';
import { StyleSheet, View } from 'react-native';
import CoreStyles from '../../styles/styles';
import Loader from '../Loader';
import { downloadPhotoById, getPhotoById } from '../../core/service/PhotoService';
import GestureRecognizer from 'react-native-swipe-gestures';
import { Image } from 'react-native-elements';
import DropMenu from '../shared/drop-menu/DropMenu';
import { showErrorToast, showToast } from '../../core/service/ToastService';
import Share from 'react-native-share';
import { FILE_RESPONSE_TYPE } from '../../core/service/FileService';

class PhotoSlide extends React.Component {

    photos = [];
    selectedPhotoId = null;
    photoRequestIntervalId = null;
    menuItems = [
        { label: 'Share', icon: 'share-alt', hasDivider: true, onPress: () => { this.sharePhoto(this.state.currentPhoto) } },
        { label: 'Download', icon: 'save', onPress: () => { this.downloadPhoto(this.state.currentPhoto) } }
    ];

    constructor(props) {
        super(props);
        this.photos = props.route?.params?.photos;
        this.selectedPhotoId = props.route?.params?.selectedPhotoId;

        this.state = {
            currentPhoto: {},
            showLoader: false
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

            if (this.photoRequestIntervalId) {
                clearInterval(this.photoRequestIntervalId);
            }

            this.setState({ currentPhoto: photo, showLoader: true }, () => {
                if (this.state.currentPhoto.source?.uri) {
                    this.setState({ ...this.state, showLoader: false });
                    return;
                }

                this.photoRequestIntervalId = setTimeout(() => {
                    getPhotoById(photoId)
                        .then((res) => {
                            if (res) {
                                if (photo.id == this.state.currentPhoto.id) {
                                    photo.source = {
                                        uri: res
                                    };
                                    const selectedPhoto = this.photos.find(item => item.id == photo.id);
                                    selectedPhoto.source = {
                                        uri: res
                                    };
                                    this.setState({ currentPhoto: { ...photo }, showLoader: false });
                                } else {
                                    this.setState({ ...this.state, showLoader: false });
                                }
                            }
                        })
                        .catch(error => {
                            showErrorToast();
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

    sharePhoto(photo) {
        showToast(`Preparing ${photo.name} for sharing.`);
        this.setState({ ...this.state, showLoader: true });

        const params = {
            responseType: FILE_RESPONSE_TYPE.BASE64,
            mimeType: photo.mimeType
        };

        getPhotoById(photo.id, params)
            .then((res) => {
                this.setState({ ...this.state, showLoader: false });
                try {
                    Share.open({
                        filename: photo.name,
                        message: 'Shared by Snap Crescent.',
                        url: res,
                        title: photo.name,
                        type: photo.mimeType
                    }).then(() => {
                        showToast(`${photo.name} has been shared.`);
                    });
                } catch (error) {
                    showErrorToast();
                }
            }).catch(error => {
                showErrorToast();
            });
    }

    downloadPhoto(photo) {
        showToast(`Downloading ${photo.name}`);
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
                        <View>
                            {this.state.showLoader ? <View style={CoreStyles.loader}><Loader /></View> : null}
                            {
                                !this.state.currentPhoto?.source?.uri
                                    ? <Image
                                        source={this.state.currentPhoto?.thumbnailSource}
                                        style={styles.image}
                                        PlaceholderContent={<Loader />} />
                                    :
                                    <Image
                                        source={this.state.currentPhoto?.source}
                                        style={styles.image}
                                        PlaceholderContent={<Loader />} />
                            }
                        </View>
                    </GestureRecognizer>
                </View>
            </View >
        );
    }
}

const styles = StyleSheet.create({
    imageContainer: {
        flex: 1,
        justifyContent: 'center',
        alignContent: 'center',
        backgroundColor: '#000000aa'
    },
    image: {
        width: '100%',
        height: '100%',
        resizeMode: 'contain'
    }
});

export default PhotoSlide;