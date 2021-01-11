import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import { useSelector } from 'react-redux';
import { searchImage } from '../../../core/service/ImageService';
import coreStyles from '../../../styles/styles';
import GridView from '../../grid-view/GridView';
import Loader from '../../Loader';

const initialState = {
    imageList: [],
    dataFecthed: false
};

function Home() {

    const [state, setState] = useState(initialState);
    const serverUrl = useSelector(state => state.serverUrl);

    useEffect(() => {
        searchImage().then(res => {
            if (res) {
                const images = res.content.map(item => {
                    return {
                        id: item.id,
                        createdDate: item.metadata.createdDate,
                        device: item.metadata.model ? item.metadata.model : 'Unknown',
                        size: item.metadata.size,
                        thumbnail: getThumbnailPath(item.thumbnailId)
                    }
                });

                setState({ ...state, imageList: images, dataFecthed: true });
            }
        });
    }, []);

    const getThumbnailPath = (props) => {
        return serverUrl + "/thumbnail/" + props;
    };

    return (
        <View style={coreStyles.flex1}>
            {
                !state.dataFecthed
                    ? <Loader />
                    : <GridView
                        data={state.imageList}
                        columnSize="4"
                        primaryKey="id"
                        imageKey="thumbnail" />
            }
        </View>
    );
}

export default Home;