# =========================
# Basic Data Structures Demo
# =========================

# --- Array ---
print("=== Array ===")
arr = [1, 2, 3, 4, 5]
print("Initial array:", arr)

print("Element at index 3:", arr[3])
arr[2] = 10
print("After updating index 2:", arr)

arr.pop(4)
print("After deleting index 4:", arr)


# --- Stack ---
print("\n=== Stack ===")
stack = []
stack.append("A")
stack.append("B")
stack.append("C")
print("Stack after push:", stack)

top = stack.pop()
print("Popped:", top)
print("Is stack empty?", len(stack) == 0)
print("Final stack:", stack)


# --- Queue ---
print("\n=== Queue ===")
queue = []
queue.append("X")
queue.append("Y")
queue.append("Z")
print("Queue after enqueue:", queue)

front = queue.pop(0)
print("Dequeued:", front)
print("Is queue empty?", len(queue) == 0)
print("Final queue:", queue)


# --- List ---
print("\n=== List ===")
my_list = []
my_list.insert(0, "Apple")
my_list.insert(1, "Banana")
my_list.insert(2, "Cherry")
print("List after inserts:", my_list)

print("Element at index 1:", my_list[1])
my_list[2] = "Grapes"
print("After updating index 2:", my_list)

del my_list[0]
print("Final list:", my_list)


# --- Hash Table ---
print("\n=== Hash Table ===")
my_dict = {}
my_dict["John"] = "Smith"
my_dict["Jane"] = "Doe"
my_dict["Bob"] = "Johnson"
print("Hash table after inserts:", my_dict)

print("Value for Jane:", my_dict["Jane"])
my_dict["Bob"] = "Anderson"
print("After updating Bob:", my_dict)

del my_dict["John"]
print("Final hash table:", my_dict)


# --- Binary Search Tree ---
print("\n=== Binary Search Tree ===")


class Node:
    """BST node with value, left, and right children."""
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None


def insert(root, value):
    """Insert value into BST."""
    if root is None:
        return Node(value)
    if value < root.value:
        root.left = insert(root.left, value)
    else:
        root.right = insert(root.right, value)
    return root


def inorder(root):
    """In-order traversal of BST."""
    if root is None:
        return []
    return inorder(root.left) + [root.value] + inorder(root.right)


def search(root, value):
    """Search value in BST."""
    if root is None:
        return False
    if root.value == value:
        return True
    elif value < root.value:
        return search(root.left, value)
    else:
        return search(root.right, value)


def delete(root, value):
    """Delete value from BST."""
    if root is None:
        return None
    if value < root.value:
        root.left = delete(root.left, value)
    elif value > root.value:
        root.right = delete(root.right, value)
    else:
        if root.left is None:
            return root.right
        if root.right is None:
            return root.left
        # find min in right subtree
        temp = root.right
        while temp.left:
            temp = temp.left
        root.value = temp.value
        root.right = delete(root.right, temp.value)
    return root


# Create tree
root = None
for v in [8, 3, 10, 1, 6, 14, 4, 7, 13]:
    root = insert(root, v)

print("Is 6 in the tree?", search(root, 6))

root = delete(root, 10)
print("In-order traversal after deleting 10:", inorder(root))
