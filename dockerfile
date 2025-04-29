FROM nvcr.io/nvidia/pytorch:24.05-py3

ARG USER=standard
ARG USER_ID=1006
ARG USER_GROUP=standard
ARG USER_GROUP_ID=1006
ARG USER_HOME=/home/${USER}

# Create user and group
RUN groupadd --gid $USER_GROUP_ID $USER \
    && useradd --uid $USER_ID --gid $USER_GROUP_ID -m $USER

# Install basic system dependencies
RUN apt-get update && apt-get install -y curl

# Copy requirements first to leverage Docker caching
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies as root
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Switch to non-root user
USER $USER

# Copy project files
COPY ./pangaea ./pangaea

# Set working directory
WORKDIR /workspace

# Make Python see pangaea
ENV PYTHONPATH=/workspace

# Default command
CMD ["torchrun", "--nnodes=1", "--nproc_per_node=1", "pangaea/run.py", \
     "--config-name=train", \
     "dataset=hlsburnscars", \
     "encoder=remoteclip", \
     "decoder=seg_upernet", \
     "preprocessing=seg_default", \
     "criterion=cross_entropy", \
     "task=segmentation"]
