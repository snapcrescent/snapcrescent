import React from 'react';
import { Image, StyleSheet, View } from "react-native";
import CoreStyles, { THEME_COLORS } from "../../../styles/styles";

function SplashScreen(props) {

    return (
        <View style={styles.container}>
            <Image source={require('../../../assets/Logo.png')} style={styles.image} />
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        ...CoreStyles.flex1,
        ...CoreStyles.centerAlignedContainer,
        backgroundColor: THEME_COLORS.secondary
    },
    image: {
        resizeMode: 'center'
    }
});

export default SplashScreen;