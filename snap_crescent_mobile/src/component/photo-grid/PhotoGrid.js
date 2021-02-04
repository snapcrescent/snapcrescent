import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import CoreStyles from '../../styles/styles';
import { searchPhoto } from '../../core/service/PhotoService';
import GridView from '../shared/grid-view/GridView';
import Loader from '../Loader';
import { showToast } from './../../core/service/ToastService';

const initialState = {
    photoList: [],
    totalPages: 0,
    totalElements: 0,
    dataFecthed: false
};

function PhotoGrid(props) {

    const { navigation } = props;
    const [state, setState] = useState(initialState);
    let page = 0;

    useEffect(() => {
        getPhotos();
    }, []);

    const getPhotos = (refreshFromServer = false, overrideStoredPhotos = false) => {
        return searchPhoto(
            { page: page },
            refreshFromServer,
            overrideStoredPhotos,
            (res) => {
                if (res) {
                    setState({
                        ...state,
                        photoList: res.data,
                        totalElements: res.totalElements,
                        totalPages: res.totalPages,
                        dataFecthed: true
                    });
                }
            });
    }

    const onGridItemClick = (item) => {
        navigation.navigate(
            'photo-slide',
            {
                photos: state.photoList.filter(photo => !photo.isEmpty),
                selectedPhotoId: item.id
            }
        );
    };

    const handleOnEndReached = () => {
        if (state.photoList.length < state.totalElements) {
            page = page + 1;
            getPhotos(true, false);
        }
    }

    return (
        <View style={CoreStyles.flex1}>
            {
                !state.dataFecthed
                    ? <Loader />
                    : <GridView
                        data={state.photoList}
                        primaryKey="id"
                        imageKey="thumbnailSource"
                        onGridPress={item => onGridItemClick(item)}
                        onRefresh={() => { return getPhotos(true, true) }}
                        onEndReached={() => { handleOnEndReached() }} />
            }
        </View>
    );

}

export default PhotoGrid;