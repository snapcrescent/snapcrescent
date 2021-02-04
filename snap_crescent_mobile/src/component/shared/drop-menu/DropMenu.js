import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from "react-native";
import Menu, { MenuDivider, MenuItem } from "react-native-material-menu";
import { isNotNull } from "../../../utils/CoreUtil";
import FontAwesome5Icon from 'react-native-vector-icons/FontAwesome5';

function DropMenu(props) {
    const { items, dropIcon, dropIconStyle, dropLabel, dropLabelStyle } = props;
    let menuRef = null;

    const menuTriggerButton = (
        <TouchableOpacity
            onPress={() => { menuRef?.show() }}
            style={{ paddingHorizontal: 5, marginHorizontal: 5 }}>
            {
                isNotNull(dropLabel)
                    ? <Text style={[styles.dropTrigger, dropLabelStyle]}>{dropLabel}</Text>
                    : <FontAwesome5Icon
                        name={dropIcon ? dropIcon : 'ellipsis-v'}
                        style={[styles.dropTrigger, dropIconStyle]} />
            }
        </TouchableOpacity>
    );

    return (
        <Menu
            ref={(ref) => { menuRef = ref }}
            button={menuTriggerButton}>
            {
                items.map(item => {
                    return (
                        <View>
                            <MenuItem onPress={() => { item.onPress() }}>{item.label}</MenuItem>
                            {
                                item.hasDivider
                                    ? <MenuDivider />
                                    : null
                            }
                        </View>
                    )
                })
            }
        </Menu>
    )
}

const styles = StyleSheet.create({
    dropTrigger: {
        fontSize: 20,
        color: '#fff'
    }
});

export default DropMenu;