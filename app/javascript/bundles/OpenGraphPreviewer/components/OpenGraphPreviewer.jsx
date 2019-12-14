import axios from 'axios'
import React from 'react'
//TODO(stevesims330): You might wanna make your own input field instead but still use MaterialUI's circular spinner.
import TextField from '@material-ui/core/TextField'

export default class OpenGraphPreviewer extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      imageUrl: null,
      errorMessage: null
    }
    this.typingTimeout = null
    this.fetchingTimeout = null
  }

  fetchImage = (event) => {
    const searchText = event.target.value;
    if (this.typingTimeout) {
        clearTimeout(this.typingTimeout)
    }
    if (searchText == null || searchText.length < 1) {
      this.setState({imageUrl: null, errorMessage: null})
      return
    }
    const halfSecondTimeoutInMs = 500
    this.typingTimeout = setTimeout(() => {
      axios.get(`/api/v1/image_parser/begin_fetch?url=${searchText}`)
        .then((result) => {
          const requestId = result.data
          // Unfortunately, since I'm already in a timeout, "this" needs to be passed down despite using arrow functions throughout.
          this.completeFetch(this, requestId)
        }).catch(function (error) {
          this.setState({
            imageUrl: null,
            errorMessage: `Error ${error.response.status}: OpenGraphPreviewer is currently unavailable. We will be back soon!`
          })
        })
    }, halfSecondTimeoutInMs)
  }

  /**
    Poll the backend up to four times to see if the job has completed. The first request will fire after one second no matter what.
    The subsequent ones will back off exponentially:
      The second will fire 2 seconds after the first one receives an erroneous response.
      The third will fire 4 seconds after the first one receives an erroneous response.
      The fourth will fire 8 seconds after the first one receives an erroneous response.
    I chose an exponential back off, as opposed to a linear one, so that a lot of clients don't overload the server.
   */
  completeFetch = (self, requestId, attempts = 0) => {
    if (self.fetchingTimeout) {
        clearTimeout(self.fetchingTimeout)
    }
    if (attempts === 4) {
      this.setState({
        imageUrl: null,
        errorMessage: "Sorry, we couldn't load the Open Graph image. Please try again!"
      })
      return
    }

    const timeoutInMs = Math.pow(2, attempts) * 1000

    self.fetchingTimeout = setTimeout(() => {
      axios.get(`/api/v1/image_parser/get_fetched_url?request_id=${requestId}`)
      .then((result) => {
        this.setState({imageUrl: result.data.url, errorMessage: result.data.error})
        return
      }).catch(function (error) {
        self.completeFetch(self, requestId, attempts + 1, error)
      })
    }, timeoutInMs)
  }

  render() {
    const { imageUrl, errorMessage } = this.state
    return (
      <div>
        <form>
          <TextField label="Enter URL" variant="outlined" onChange={this.fetchImage}/>
        </form>
        {imageUrl &&
          <img src={imageUrl}/>
        }
        {!imageUrl &&
          <div>{errorMessage}</div>
        }
      </div>
    )
  }
}
