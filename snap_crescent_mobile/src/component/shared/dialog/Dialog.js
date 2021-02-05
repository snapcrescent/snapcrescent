import React from 'react';
import { Modal, View } from "react-native";
import CloseIcon from '../close-icon/CloseIcon';
import DialogStyle from './DialogStyle';

function Dialog(props) {

    const { showDialog, template, showCloseButton, onClose, dialogStyle } = props;

    return (
        <Modal transparent={true} visible={showDialog}>
            <View style={[DialogStyle.outerContainer, dialogStyle?.outerContainer]}>
                <View style={[DialogStyle.innerConatiner, dialogStyle?.innerConatiner]}>
                    {showCloseButton ? <CloseIcon onPress={() => { onClose() }} /> : null}
                    {template}
                </View>
            </View>
        </Modal >
    );
}

export default Dialog;