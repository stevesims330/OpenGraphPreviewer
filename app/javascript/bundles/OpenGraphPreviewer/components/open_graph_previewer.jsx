import React from 'react'

import axios from 'axios'

import validator from 'validator'

import LinearProgress from '@material-ui/core/LinearProgress'
import Paper from '@material-ui/core/Paper'
import TextField from '@material-ui/core/TextField'
import { createMuiTheme, MuiThemeProvider } from '@material-ui/core/styles'

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
    /*
      Since creating themes can be expensive, I moved the theme from the render method. I didn't notice any performance
      issues before I moved it but putting it here from the beginning would prevent performance issues in the future.

      From https://material-ui.com/customization/theming/:
        "If you provide a new theme at each render, a new CSS object will be computed and injected. Both for UI
        consistency and performance, it's better to render a limited number of theme objects."

      In a larger app, I'd want to define the theme somewhere that would let me share it between components.
    */
    this.theme = createMuiTheme({
      palette: {
        primary: {
          main: '#6d31ff',
        },
        secondary: {
          main: '#53efce',
        },
      },
    })
  }

  fetchImage = (event) => {
    const url = event.target.value
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout)
    }
    /*
      Clearing the fetchingTimeout makes sure currently pending requests don't complete, for example, if the user holds down backspace while
      a request is loading. Before I added this, the user could delete the URL and the image would load anyway.

      Another option would have been to grey out the TextField, but that would have led to a poor user experience: Users
      would either make a lot of accidental fetches and have to wait a long time before they could correct their fetch, or I'd have to increase
      the halfSecondTimeoutInMs substantially. This would be less bad, but it would make the app feel less slick.
    */
    if (this.fetchingTimeout) {
      clearTimeout(this.fetchingTimeout)
    }
    this.setState({imageUrl: null, errorMessage: null, loading: false})

    const halfSecondTimeoutInMs = 500
    this.typingTimeout = setTimeout(() => {

      // I originally validated URL's outside the typingTimeout, but that spammed me with invalid URL error messages while I was typing.
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
      axios.get(`/api/v1/image_parser/begin_fetch?url=${url}`)
        .then((result) => {
          const requestId = result.data
          // Unfortunately, since I'm already inside a timeout, "this" needs to be passed down despite using arrow functions throughout.
          this.completeFetch(this, requestId)
        }).catch(function (error) {
          this.setState({
            imageUrl: null,
            errorMessage: `Error ${error.response.status}: OpenGraphPreviewer is currently unavailable. We will be back soon!`,
            loading: false
          })
        })
    }, halfSecondTimeoutInMs)
  }

  /*
    Poll the backend up to four times to see if the job has completed. The first request will fire after 1 second no matter what.
    The subsequent ones will back off exponentially:
      The second will fire 2 seconds after the first receives an error.
      The third will fire 4 seconds after the second receives an error.
      The fourth will fire 8 seconds after the second receives an error.
    I chose an exponential back off so that a lot of clients don't overload the server, as they could if I were polling, say, every second.

    How many attempts, and the rate of the back off, would definitely be something to be tweaked as the app scales. I became frustrated when
    I got to the fourth wait.
  */
  completeFetch = (self, requestId, attempts = 0) => {
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

    const timeoutInMs = Math.pow(2, attempts) * 1000

    self.fetchingTimeout = setTimeout(() => {
      axios.get(`/api/v1/image_parser/get_fetched_url?request_id=${requestId}`)
      .then((result) => {
        this.setState({ imageUrl: result.data.url, errorMessage: result.data.error, loading: false })
        return
      }).catch(function (error) {
        self.completeFetch(self, requestId, attempts + 1, error)
      })
    }, timeoutInMs)
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
                  <TextField fullWidth color="primary" label="Enter URL" variant="outlined" onChange={this.fetchImage}/>
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
