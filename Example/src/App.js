/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Dimensions,
  StatusBar
} from 'react-native';

import { Session, PublisherView, SubscriberView } from 'react-native-hot-box'

import Footer from './Buttons'

var { width, height } = Dimensions.get('window')

var session = new Session()

export default class App extends Component {
  state = {
    publishing: false,
    subscriberIds: [],
    publishingVideo: false,
    publishingAudio: false
  }

  connect = () => {
    let apiKey = '45929062'
    let sessionId = '2_MX40NTkyOTA2Mn5-MTUxNjkxMTM2ODUwNH5NYWw0Q2FpdlV1N1pydmJTQzZmeERLSnV-fg'
    let token = 'T1==cGFydG5lcl9pZD00NTkyOTA2MiZzaWc9ZjA0MTI1YTQ2NTQ0NmRlNjRhNTYyOGZhNzcxOGRhYTViOGU5NzU0NTpzZXNzaW9uX2lkPTJfTVg0ME5Ua3lPVEEyTW41LU1UVXhOamt4TVRNMk9EVXdOSDVOWVd3MFEyRnBkbFYxTjFweWRtSlRRelptZUVSTFNuVi1mZyZjcmVhdGVfdGltZT0xNTE2OTExNDE3Jm5vbmNlPTAuNDQ5NzAwNTQ0NTY3MDg2OTcmcm9sZT1wdWJsaXNoZXImZXhwaXJlX3RpbWU9MTUxNjkzMzAxNyZpbml0aWFsX2xheW91dF9jbGFzc19saXN0PQ=='

    session.createSession(apiKey, sessionId, token)
  }

  didDisconnect = () => {
    this.setState({
      publishing: false,
      subscriberIds: []
    })
  }

  didConnect = () => {
    this.setState({
      publishing: true,
      publishingVideo: true,
      publishingAudio: true
    })
  }

  renderSubscribers = () => {
    if (this.state.subscriberIds.length === 0) return null

    return this.state.subscriberIds.map((streamId) => {
      return <SubscriberView key={streamId} style={styles.viewStyle} streamId={streamId} />
    })
  }

  subscriberConnected = (streamId) => {
    this.setState(previousState => ({
      subscriberIds: [...previousState.subscriberIds, streamId]
    }));
  }

  subscriberDisconnected = (streamId) => {
    var filtered = this.state.subscriberIds.filter((streamId) => streamId !== streamId)
    
    console.warn("why")
    console.log('Subscriber Disconnected2222', streamId)
    console.log(new Error().stack);

    this.setState(previousState => ({
      subscriberIds: filtered
    }))
  }

  streamDestroyed = (test) => {
    var filtered = this.state.subscriberIds.filter((streamId) => streamId !== streamId)

    this.setState(previousState => ({
      subscriberIds: filtered
    }))
  }

  receivedSignal = ({ type, connectionId, string }) => {
    console.log('Received a message', type, connectionId, string)
  }

  toggleVideo = () => {
    session.requestVideoStream(null, !this.state.publishingVideo)
    this.setState(previousState => ({
      publishingVideo: !previousState.publishingVideo
    }));
  }

  touchMiddle = () => {
    // session.broadcastMessage('StartGame', 'flappy-lives')
    session.modifySubscriberStream(true, null, { "width": 352, "height": 288 }, 1)
  }

  toggleAudio = () => {
    session.requestAudioStream(null, !this.state.publishingAudio)
    this.setState(previousState => ({
      publishingAudio: !previousState.publishingAudio
    }));
  }

  toggleScreen = () => {
    session.requestCameraSwap(true)
  }

  subscriberVideoEnabled = (streamId) => {
    console.log("Stream ", streamId, ' Enabled Video')
  }

  subscriberVideoDisabled = (streamId) => {
    console.log("Stream ", streamId, ' Disabled Video')
  }

  componentDidMount() {

    session.on('sessionDidConnect', () => this.didConnect())
    session.on("sessionDidDisconnect", () => this.didDisconnect())
    session.on('publisherStreamCreated', () => console.log("PUBLISHER CREATED"))
    session.on('sessionStreamCreated', () => console.log('sessionStreamCreated'))

    // session.on('subscriberDidDisconnect', (streamId) => {
    //   console.warn("why")
    //   console.log('Subscriber Disconnected2222', streamId)
    // })
    session.on("subscriberDidDisconnect", this.subscriberDisconnected)

    session.on('subscriberDidConnect', this.subscriberConnected)
    
    session.on('sessionStreamDestroyed', this.streamDestroyed)
    session.on('sessionReceivedSignal', this.receivedSignal)
    session.on('subscriberVideoEnabled', this.subscriberVideoEnabled)
    session.on('subscriberVideoDisabled', this.subscriberVideoDisabled)

    this.connect()
  }

  render() {
    console.disableYellowBox = true;

    let hasSub = this.state.subscriberIds.length >= 1
    let viewCount =
      (hasSub ? this.state.subscriberIds.length : 0) +
      (this.state.publishing ? 1 : 0)
    let showTwoStyle = viewCount === 2 ? styles.two : {};


    return (
      <View style={styles.fullscreen}>
        <StatusBar hidden={true} />
        <View style={[styles.container, showTwoStyle]}>
          {hasSub ? this.renderSubscribers() : null}
          {this.state.publishing
            ? <PublisherView style={styles.viewStyle} />
            : null}
        </View>

        <View style={styles.fullscreen}>
          <Footer
            publishingVideoTouch={this.toggleVideo}
            publishingAudioTouch={this.toggleAudio}

            touchMiddle={this.touchMiddle}

            publishingAudio={this.state.publishingAudio}
            publishingVideo={this.state.publishingVideo}
          />
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    display: "flex",
    backgroundColor: "transparent",
    flexDirection: "row",
    flexWrap: "wrap",
    alignItems: "stretch",
    alignContent: "stretch",
    height,
    width
  },
  viewStyle: {
    minWidth: width / 2,
    flexGrow: 1
  },
  two: {
    flexDirection: "column"
  },
  fullscreen: {
    position: "absolute",
    top: 0,
    right: 0,
    left: 0,
    bottom: 0
  }
});