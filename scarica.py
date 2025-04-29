import timm
import torch

model = timm.create_model('vit_tiny_patch16_224', pretrained=True)
torch.save(model.state_dict(), 'vit_tiny_patch16_224.pth')
