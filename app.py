from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# Simple in-memory list - resets whenever the app restarts.
# Good enough for learning the pipeline; a real app would use a database.
todos = []


@app.route("/")
def index():
    return render_template("index.html", todos=todos)


@app.route("/add", methods=["POST"])
def add():
    task = request.form.get("task", "").strip()
    if task:
        todos.append({"task": task, "done": False})
    return redirect(url_for("index"))


@app.route("/toggle/<int:todo_id>")
def toggle(todo_id):
    if 0 <= todo_id < len(todos):
        todos[todo_id]["done"] = not todos[todo_id]["done"]
    return redirect(url_for("index"))


@app.route("/delete/<int:todo_id>")
def delete(todo_id):
    if 0 <= todo_id < len(todos):
        todos.pop(todo_id)
    return redirect(url_for("index"))


@app.route("/health")
def health():
    # Kubernetes will call this later to check if the pod is alive
    return {"status": "ok"}, 200

# This is the main entry point for the Flask app. It runs the app on all available network interfaces (
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
