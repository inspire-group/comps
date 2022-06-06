import flask

app = flask.Flask(__name__)

@app.route("/ip")
def ip_address():
    ip_address = flask.request.remote_addr
    return "Requester: " + ip_address

@app.route("/file")
def large_file():
    size = flask.request.args.get('size', default = 1, type = int)
    file_name = '/data/file_{size}M.dat'.format(size = size)
    return flask.send_file(file_name)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)

