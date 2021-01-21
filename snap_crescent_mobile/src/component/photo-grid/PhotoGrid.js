import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import CoreStyles from '../../styles/styles';
import { searchPhoto } from '../../core/service/PhotoService';
import GridView from '../grid-view/GridView';
import Loader from '../Loader';

const initialState = {
    photoList: [],
    dataFecthed: false
};

function PhotoGrid(props) {

    const { navigation } = props;
    const [state, setState] = useState(initialState);

    useEffect(() => {
        getPhotos();
    }, []);

    const getPhotos = () => {
        return searchPhoto().then(res => {
            if (res) {
                setState({ ...state, photoList: res, dataFecthed: true });
                return res;
            }

            return null;
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
                        onRefresh={() => { return getPhotos() }} />
            }
        </View>
    );

}

export default PhotoGrid;