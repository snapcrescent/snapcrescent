import React from 'react';
import { ActivityIndicator, StyleSheet, View } from "react-native";
import { THEME_COLORS } from '../styles/styles';

export default function Loader(props) {

    return (
        <View style={styles.container}>
            <ActivityIndicator size='large' color={THEME_COLORS.primary} />
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