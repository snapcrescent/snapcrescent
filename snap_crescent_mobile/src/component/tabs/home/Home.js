import React, { useEffect, useState } from 'react';
import { ActivityIndicator } from 'react-native';
import { FlatList, SafeAreaView, StyleSheet, Text, View } from 'react-native';
import { Image } from 'react-native-elements';
import { useSelector } from 'react-redux';
import { searchImage } from '../../../core/service/ImageService';

const initialState = {
    imageList: []
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

                setState({ imageList: images });
            }
        });
    }, []);

    const getThumbnailPath = (props) => {
        return "http://" + serverUrl + "/thumbnail/" + props;
    };

    return (
        <SafeAreaView style={styles.container}>
            <FlatList
                data={state.imageList}
                renderItem={({ item }) => (
                    <View style={styles.imageContainer}>
                        <Image
                            source={{ uri: item.thumbnail }}
                            style={styles.image}
                            transition={true}
                            transitionDuration={5000}
                            PlaceholderContent={<ActivityIndicator />}
                        />
                    </View>
                )}
                numColumns="2"
                keyExtractor={item => item.id}
            />
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1
    },
    imageContainer: {
        flex: 1,
        flexDirection: 'column',
        margin: 1
    },
    image: {
        width: 200,
        height: 200
    }
});

export default Home;