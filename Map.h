#ifndef MAP_H
#define MAP_H

#include <string>
#include <iostream>

struct node
{
    std::string key;
    std::string value;
    struct node *left, *right;
};

class Map
{
public:
    Map()
    {
        root = 0;
    }

    std::string & operator[](const std::string &key)
    {
        if (root == 0)
        {
            root = new struct node();
            root->key = std::string(key);
            root->left = 0;
            root->right = 0;
            return root->value;
        }

        struct node *tmp = root;

        while (key != tmp->key)
        {
            if (key < tmp->key)
            {
                if (tmp->left == 0)
                {
                    tmp->left = new struct node();
                    tmp = tmp->left;
                    tmp->key = key;
                    tmp->left = 0;
                    tmp->right = 0;
                    break;
                }
                tmp = tmp->left;
            }
            else if (key > tmp->key)
            {
                if (tmp->right == 0)
                {
                    tmp->right = new struct node();
                    tmp = tmp->right;
                    tmp->key = key;
                    tmp->left = 0;
                    tmp->right = 0;
                    break;
                }
                tmp = tmp->right;
            }
        }

        return tmp->value;
    }

private:
    struct node *root;
};

#endif /* MAP_H */
