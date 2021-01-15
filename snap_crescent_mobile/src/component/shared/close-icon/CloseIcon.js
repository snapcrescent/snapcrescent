import React from 'react';
import { StyleSheet, TouchableOpacity, View } from "react-native";
import FontAwesome5Icon from "react-native-vector-icons/FontAwesome5";
import CoreStyles from "../../../styles/styles";

function CloseIcon(props) {

    const { onPress } = props;

    return (
        <View style={CoreStyles.rightAlignedContainer}>
            <TouchableOpacity
                style={styles.closeIconContainer}
                onPress={() => { onPress() }}>
                <FontAwesome5Icon name="times-circle" style={CoreStyles.closeIcon} />
            </TouchableOpacity>
        </View>
    );
}

const styles = StyleSheet.create({
    closeIconContainer: {
        padding: 5
    }
});

export default CloseIcon;