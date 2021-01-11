import React from 'react';
import { ActivityIndicator, StyleSheet, View } from "react-native";

export default function Loader() {
    return (
        <View style={styles.container}>
            <ActivityIndicator size='large' color='#15c57e' />
        </View>
    )
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        margin: 5,
        justifyContent: 'center'
    }
})