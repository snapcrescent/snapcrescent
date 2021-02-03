import React from 'react';
import { StyleSheet, View } from 'react-native';
import CoreStyles from '../../styles/styles';
import Loader from '../Loader';
import { downloadPhotoById, getPhotoById } from '../../core/service/PhotoService';
import GestureRecognizer from 'react-native-swipe-gestures';
import { Image } from 'react-native-elements';
import { showToast } from '../../core/service/ToastService';
import DropMenu from '../shared/drop-menu/DropMenu';

const IMAGE_URL_PREFIX = 'data:image/*;base64,';
class PhotoSlide extends React.Component {

    photos = [];
    selectedPhotoId = null;
    photoRequestIntervalId = null;
    menu = null;
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
            const photo = {
                ...this.photos[indexOfPhoto],
                index: indexOfPhoto,
                label: this.getPhotoLabel(this.photos[indexOfPhoto])
            };

            this.setState({ currentPhoto: photo }, () => {
                if (this.photoRequestIntervalId) {
                    clearInterval(this.photoRequestIntervalId);
                }

                this.photoRequestIntervalId = setTimeout(() => {
                    getPhotoById(photoId).then((res) => {
                        if (res) {
                            if (photo.id == this.state.currentPhoto.id) {
                                photo.source = {
                                    uri: IMAGE_URL_PREFIX + res
                                };
                                this.setState({ currentPhoto: { ...photo } })
                            }
                        }
                    });
                }, 1000);
            });

        } else {
            this.setState({ currentPhoto: null });
        }
    }

    downloadPhoto(photo) {
        downloadPhotoById(photo.id, photo.name).then(res => {
            showToast(photo.name + ' has been downloded');
        });
    }

    getPhotoLabel(photo) {
        if (photo.createdDate) {
            return new Date(photo.createdDate).toDateString();
        } else {
            return photo.name;
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

    render() {
        return (
            <View style={CoreStyles.flex1} >
                <View style={styles.imageContainer}>
                    <GestureRecognizer
                        onSwipeLeft={() => { this.handleSwipeLeft() }}
                        onSwipeRight={() => { this.handleSwipeRight() }}>
                        {
                            !this.state.currentPhoto?.source?.uri
                                ? <Image
                                    source={this.state.currentPhoto?.thumbnailSource}
                                    style={styles.image}
                                    PlaceholderContent={<Loader />} />
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