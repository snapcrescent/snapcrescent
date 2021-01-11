import React, { useEffect, useState } from 'react';
import { ActivityIndicator, FlatList, SafeAreaView, StyleSheet, View } from 'react-native';
import { Image } from 'react-native-elements';
import { getHeaders } from '../../core/service/ApiService';

const initialState = {
    dataSource: []
};

function GridView(props) {

    const [state, setState] = useState(initialState);

    useEffect(() => {
        setState({ ...state, dataSource: props.data });
    }, [props.data, props.columnSize]);

    return (
        <SafeAreaView style={styles.viewContainer}>
            <FlatList
                data={state.dataSource}
                numColumns={props.columnSize}
                keyExtractor={item => item[props.primaryKey]}
                renderItem={({ item }) => (
                    <View style={styles.imageContainer}>
                        <Image
                            source={{
                                uri: item[props.imageKey],
                                headers: getHeaders()
                            }}
                            PlaceholderContent={<ActivityIndicator />}
                            style={styles.image}
                            transition={true}
                            transitionDuration={4000}>
                        </Image>
                    </View>
                )}>
            </FlatList>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    viewContainer: {
        flex: 1,
        marginTop: 20,
        padding: 5
    },
    imageContainer: {
        flex: 1,
        flexDirection: 'column',
        margin: 1
    },
    image: {
        width: 100,
        height: 100
    }
})

export default GridView;