import React, { useState, useCallback, useEffect } from 'react';
import { View, StyleSheet, Dimensions, Animated, Modal, TouchableOpacity, ScrollView, TouchableWithoutFeedback } from 'react-native';
import moment from 'moment';
import invariant from 'invariant';

import RNMonthPickerView from './RNMonthPickerNativeComponent';
import {
  ACTION_DATE_SET,
  ACTION_DISMISSED,
  ACTION_NEUTRAL,
  NATIVE_FORMAT,
  DEFAULT_MODE,
} from './constants';

const { width } = Dimensions.get('screen');
const { Value, timing } = Animated;

const styles = StyleSheet.create({
  container: {
    flex:1
  },
  scrollModal:{
    flex:1
  },
  pickerContainer: {
    height: 244,
    width: width - 30,
    position: 'absolute',
    alignSelf:"center",
    zIndex: 500,
    borderRadius:10,
    overflow:"hidden",
    bottom: 0,
  },
  picker: { flex: 1 },
});

const MonthPicker = ({
  value,
  isVisible,
  onHide,
  minimumDate,
  maximumDate,
  onChange: onAction,
  locale = '',
  mode = DEFAULT_MODE,
  okButton,
  cancelButton,
  neutralButton,
  autoTheme = true,
  theme = "light"
}) => {
  invariant(value, 'value prop is required!');

  const [opacity] = useState(new Value(0));
  const [pickerVisible, setPickerVisible] = useState(isVisible)
  const [selectedDate, setSelectedDate] = useState(value);

  useEffect(() => {
    timing(opacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,
    }).start();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const onChange = useCallback(
    ({ nativeEvent: { newDate } }) => {
      setSelectedDate(moment(newDate, NATIVE_FORMAT).toDate()),
      setPickerVisible(false)},
    [],
  );

  const slideOut = useCallback(
    (callback) =>
      timing(opacity, {
        toValue: 0,
        duration: 250,
        useNativeDriver: true,
      }).start(callback),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [],
  );

  const onDone = useCallback(() => {
    slideOut(
      ({ finished }) => {
        finished && onAction && onAction(ACTION_DATE_SET, selectedDate),
        setPickerVisible(false)
      }
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedDate]);

  const onCancel = useCallback(() => {
    slideOut(
      ({ finished }) =>
        finished && onAction && onAction(ACTION_DISMISSED, undefined),
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const onNeutral = useCallback(() => {
    slideOut(
      ({ finished }) =>
        finished && onAction && onAction(ACTION_NEUTRAL, selectedDate),
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedDate]);

  return (
    <Modal
      animationType="slide"
        transparent={true}
        visible={isVisible}
        onRequestClose={onCancel}>
      <TouchableOpacity 
            style={styles.container} 
            activeOpacity={1} 
            onPressOut={onCancel}
          >
            <ScrollView 
              directionalLockEnabled={true} 
              contentContainerStyle={styles.scrollModal}
            >
      <TouchableWithoutFeedback>
      <View style={styles.pickerContainer}>
        <RNMonthPickerView
          {...{
            locale,
            mode,
            onChange,
            onDone,
            onCancel,
            onNeutral,
            okButton,
            cancelButton,
            neutralButton,
            autoTheme,
            theme
          }}
          style={styles.picker}
          value={value.getTime()}
          minimumDate={minimumDate?.getTime() ?? null}
          maximumDate={maximumDate?.getTime() ?? null}
        />
      </View>
      </TouchableWithoutFeedback>
      </ScrollView>
      </TouchableOpacity>   
    </Modal>
  );
};

export default MonthPicker;
