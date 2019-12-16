import React from 'react'

import axios from 'axios'

import validator from 'validator'

import LinearProgress from '@material-ui/core/LinearProgress'
import Paper from '@material-ui/core/Paper'
import TextField from '@material-ui/core/TextField'
import { createMuiTheme, MuiThemeProvider } from '@material-ui/core/styles'

import { theme } from './theme'

export default class OpenGraphPreviewer extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      imageUrl: null,
      errorMessage: null,
      loading: false
    }
    this.typingTimeout = null
    this.fetchingTimeout = null
    this.theme = createMuiTheme(theme)
  }

  fetchImage = (event) => {
    const url = event.target.value
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
    }
    // Prevent currently pending requests from loading
    if (this.fetchingTimeout) {
      clearTimeout(this.fetchingTimeout)
    }
    this.setState({imageUrl: null, errorMessage: null, loading: false})

    const halfSecondDelayInMs = 500
    this.typingTimeout = setTimeout(() => {

      // Validate URLs after user is done typing
      const invalidUrl = !validator.isURL(url)
      if (invalidUrl) {
        let errorMessage = "Please enter a URL in the following format: https://www.example.com"
        if (url.length === 0) {
          errorMessage = null
        }
        this.setState({imageUrl: null, errorMessage: errorMessage, loading: false})
        return
      }

      this.setState({imageUrl: null, errorMessage: null, loading: true})

      self = this
      this.buildHttpClient().get(`/api/v1/image_parser/begin_fetch?website_url=${url}`)
        .then(() => {
          // Pass down "this" since we it's inside a nested arrow function
          this.completeFetch(this, url)
        }).catch(function (error) {
          self.setState({
            imageUrl: null,
            errorMessage: `Error ${error.response.status}: OpenGraphPreviewer is currently unavailable. We will be back soon!`,
            loading: false
          })
        })
    }, halfSecondDelayInMs)
  }

  // Exponential back off retries for 4 times (retry in 2s, 4s, 8s)
  completeFetch = (self, url, attempts = 0) => {
    if (self.fetchingTimeout) {
        clearTimeout(self.fetchingTimeout)
    }
    if (attempts === 4) {
      this.setState({
        imageUrl: null,
        errorMessage: "Sorry, we couldn't load the Open Graph image. Please try again!",
        loading: false
      })
      return
    }

    const delayInMs = Math.pow(2, attempts) * 1000

    self.fetchingTimeout = setTimeout(() => {
      this.buildHttpClient().get(`/api/v1/image_parser/retrieve_image_url?website_url=${url}`)
      .then((result) => {
        this.setState({ imageUrl: result.data.url, errorMessage: result.data.error, loading: false })
        return
      }).catch(function (error) {
        self.completeFetch(self, url, attempts + 1, error)
      })
    }, delayInMs)
  }

  preventPageRefresh = (event) => {
    const pressedEnterKey = event.which === 13
    if (pressedEnterKey) {
      event.preventDefault()
    }
  }

  buildHttpClient = () => {
    const httpClient = axios.create()
    const tenSecondsInMs = 10000
    httpClient.defaults.timeout = tenSecondsInMs
    return httpClient
  }

  render() {
    const { loading, imageUrl, errorMessage } = this.state
    return (
      <div id="open_graph_previewer">
        <div className="centered">
          <MuiThemeProvider theme={this.theme}>
            <Paper id="open_graph_paper">
              <div>
                <form>
                  <TextField fullWidth color="primary" label="Enter URL" variant="outlined" onChange={this.fetchImage} onKeyPress={this.preventPageRefresh}/>
                </form>
              </div>
              {loading &&
                <div id="linear_progress_wrapper">
                  <LinearProgress id="linear_progress" color="secondary"/>
                </div>
              }
              {imageUrl &&
                <div id="image_wrapper">
                  <img src={imageUrl}/>
                </div>
              }
              {errorMessage &&
                <div id="error_message">{errorMessage}</div>
              }
            </Paper>
          </MuiThemeProvider>
        </div>
      </div>
    )
  }
}
