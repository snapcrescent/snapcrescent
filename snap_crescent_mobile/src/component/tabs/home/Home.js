import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import { searchImage } from '../../../core/service/ImageService';
import CoreStyles from '../../../styles/styles';
import GridView from '../../grid-view/GridView';
import Loader from '../../Loader';
import PhotoSlide from '../../photo-slide/PhotoSlide';

const initialState = {
    imageList: [],
    dataFecthed: false
};

const initialPhotoSlideState = {
    selectedImage: null,
    showPhotoSlide: false
};

function Home() {

    const [state, setState] = useState(initialState);
    const [photoSlideState, setPhotoSlideState] = useState(initialPhotoSlideState);

    useEffect(() => {
        getImages();
    }, []);

    const getImages = () => {
        return searchImage().then(res => {
            if (res) {
                setState({ ...state, imageList: res, dataFecthed: true });
                return res;
            }

            return [];
        });
    }

    const onImageClick = (image) => {
        setPhotoSlideState({ selectedImage: image, showPhotoSlide: true });
    };

    return (
        <View style={CoreStyles.flex1}>
            {
                !state.dataFecthed
                    ? <Loader />
                    : <GridView
                        data={state.imageList}
                        columnSize="4"
                        primaryKey="id"
                        imageKey="thumbnailSource"
                        onGridPress={item => onImageClick(item)}
                        onRefresh={() => { return getImages() }} />
            }

            <PhotoSlide
                showPhotoSlide={photoSlideState.showPhotoSlide}
                images={state.imageList}
                idFieldKey="id"
                selectedImage={photoSlideState.selectedImage}
                onClose={() => { setPhotoSlideState({ ...photoSlideState, showPhotoSlide: false }); }} />
        </View>
    );
}

export default Home;