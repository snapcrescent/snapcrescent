import React, { useEffect, useState } from 'react';
import {
    ActivityIndicator,
    Dimensions,
    FlatList,
    SafeAreaView,
    StyleSheet,
    View
} from 'react-native';
import { Image } from 'react-native-elements';

const initialState = {
    dataSource: []
};

const NUMBER_OF_COLUMNS = 4;
const WINDOW_WIDTH = Dimensions.get('window').width;

function GridView(props) {

    const { data, imageKey, onGridPress, primaryKey, onRefresh, onEndReached } = props;
    const [state, setState] = useState(initialState);
    const [refreshing, setRefreshing] = useState(false);

    useEffect(() => {
        const dataList = data;
        formatData(dataList);
        setState({ ...state, dataSource: dataList });
    }, [data]);

    const formatData = (dataToFormat) => {
        dataToFormat = dataToFormat.filter(data => !data.isEmpty);
        const totalRows = Math.floor(dataToFormat.length / NUMBER_OF_COLUMNS);
        let elementsInLastRow = data.length - (totalRows * NUMBER_OF_COLUMNS);

        while (elementsInLastRow != 0 && elementsInLastRow != NUMBER_OF_COLUMNS) {
            dataToFormat.push({ isEmpty: true });
            elementsInLastRow++;
        }
    }

    const refreshData = () => {
        if (onRefresh) {
            setRefreshing(true);
            onRefresh().then((res) => {
                setTimeout(() => {
                    setRefreshing(false);
                });
            });
        }
    }

    const renderItem = ({ item }) => {
        if (item.isEmpty) {
            return (<View style={{ ...styles.imageContainer, backgroundColor: 'transparent' }} />)
        } else {
            return (
                <View style={styles.imageContainer}>
                    <Image
                        source={item[imageKey]}
                        PlaceholderContent={<ActivityIndicator />}
                        style={styles.image}
                        transition={true}
                        transitionDuration={500}
                        onPress={() => { onGridPress(item) }}>
                    </Image>
                </View>
            );
        }

    }

    return (
        <SafeAreaView style={styles.viewContainer}>
            <FlatList
                data={state.dataSource}
                numColumns={NUMBER_OF_COLUMNS}
                keyExtractor={item => item[primaryKey]}
                renderItem={renderItem}
                refreshing={refreshing}
                onRefresh={() => { refreshData() }}
                onEndReached={() => { onEndReached() }}
                onEndReachedThreshold={0.3}>
            </FlatList>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    viewContainer: {
        flex: 1,
        marginTop: 5,
        padding: 5
    },
    imageContainer: {
        flex: 1,
        flexDirection: 'column',
        margin: 1
    },
    image: {
        width: WINDOW_WIDTH / NUMBER_OF_COLUMNS,
        height: WINDOW_WIDTH / NUMBER_OF_COLUMNS,
        resizeMode: 'contain'
    }
});

export default GridView;